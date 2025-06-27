class Metric < ApplicationRecord
  include Namespaceable

  belongs_to :user

  # One-to-many relationships
  has_many :alerts, dependent: :destroy

  # Many-to-many relationships
  has_many :report_metrics, dependent: :destroy
  has_many :reports, through: :report_metrics

  has_many :metric_questions, dependent: :destroy
  has_many :questions, through: :metric_questions

  has_many :parent_metric_metrics, class_name: "MetricMetric", foreign_key: "child_metric_id", dependent: :destroy
  has_many :parent_metrics, through: :parent_metric_metrics, source: :parent_metric

  has_many :child_metric_metrics, class_name: "MetricMetric", foreign_key: "parent_metric_id", dependent: :destroy

  belongs_to :first_metric, class_name: "Metric", optional: true

  validates :resolution, presence: true, inclusion: { in: %w[five_minute hour day week month] }
  validates :width, presence: true, inclusion: { in: %w[daily weekly monthly 90_days yearly 7_days 30_days all_time] }
  validates :function, presence: true, inclusion: { in: %w[answer sum average difference count] }
  validates :wrap, inclusion: { in: %w[none hour day weekly] }, allow_nil: true
  validates :scale, numericality: { greater_than: 0 }, allow_nil: true

  attr_accessor :child_metric_ids_temp, :child_metric_ids_changed

  before_save :store_child_metric_ids
  after_save :create_child_associations

  scope :not_deleted, -> { where(deleted: false) }

  def soft_delete!
    update!(deleted: true)
  end

  def type
    case function
    when "answer"
      # Return the most common question type from referenced questions
      question_types = questions.pluck(:question_type).uniq
      question_types.first || "number"
    else
      "number" # All calculated metrics return numbers
    end
  end

  def series
    raw_series = case function
    when "answer"
      generate_answer_series
    when "sum"
      generate_sum_series
    when "average"
      generate_average_series
    when "difference"
      generate_difference_series
    when "count"
      generate_count_series
    end

    # Wrapping is now handled within each series generation method
    raw_series
  end

  def child_metric_ids=(ids)
    @child_metric_ids_temp = Array(ids).reject(&:blank?)
    @child_metric_ids_changed = true
  end

  def child_metric_ids
    if persisted?
      child_metric_metrics.pluck(:child_metric_id)
    else
      @child_metric_ids_temp || []
    end
  end

  def child_metrics
    if persisted?
      Metric.where(id: child_metric_metrics.pluck(:child_metric_id))
    else
      Metric.where(id: @child_metric_ids_temp || [])
    end
  end

  def display_name
    if name.present?
      name
    else
      id_display = id ? "##{id}" : "(New)"
      "Metric #{id_display}"
    end
  end

  private

  def wrap_timestamp(timestamp)
    # Map timestamp to position within the wrap period
    base_date = Date.current
    
    case wrap
    when "hour"
      # Map to position within a reference hour (0-59 minutes)
      base_date.beginning_of_day + timestamp.min.minutes + timestamp.sec.seconds
    when "day"
      # Map to position within a reference day (0-23:59:59)
      base_date.beginning_of_day + timestamp.hour.hours + timestamp.min.minutes + timestamp.sec.seconds
    when "weekly"
      # Map to position within a reference week (0-6 days, 0-23:59:59)
      # Convert wday (0=Sunday, 1=Monday, ...) to days from Monday start
      days_from_monday = timestamp.wday == 0 ? 6 : timestamp.wday - 1
      base_date.beginning_of_week + days_from_monday.days + timestamp.hour.hours + timestamp.min.minutes + timestamp.sec.seconds
    else
      timestamp
    end
  end

  def generate_answer_series
    # Get all answers to the referenced questions
    filtered_answers = Answer.joins(:response, :question)
                             .where(questions: { id: questions.pluck(:id) })
                             .where(responses: { user_id: user_id })
                             .where(created_at: time_range)
                             .order(:created_at)

    # If wrapping is enabled, map timestamps first, then group and average
    if wrap.present? && wrap != "none"
      # Get raw data points with wrapped timestamps
      wrapped_data = filtered_answers.map do |answer|
        value = numeric_value(answer)
        scaled_value = value * (scale || 1.0)
        wrapped_timestamp = wrap_timestamp(answer.created_at)
        [ wrapped_timestamp, scaled_value ]
      end
      
      # Group by wrapped timestamp and average overlapping values
      grouped_wrapped = wrapped_data.group_by(&:first)
      grouped_wrapped.map do |wrapped_time, time_value_pairs|
        values = time_value_pairs.map(&:last)
        averaged_value = values.sum.to_f / values.size
        [ wrapped_time, averaged_value ]
      end.sort_by(&:first)
    else
      # Use bucketing for non-wrapped data with previous value maintenance
      grouped_answers = group_by_resolution(filtered_answers)
      
      # Generate all time buckets in the range
      all_buckets = generate_time_buckets
      
      # Fill buckets with data, maintaining previous values for missing data
      previous_value = nil
      all_buckets.map do |bucket_time|
        if grouped_answers.has_key?(bucket_time)
          # Bucket has data - calculate average
          group_answers = grouped_answers[bucket_time]
          values = group_answers.map { |answer| numeric_value(answer) }
          value = values.sum.to_f / values.size
          
          # Apply scale factor for answer metrics
          scaled_value = value * (scale || 1.0)
          previous_value = scaled_value  # Update previous value
          
          [ bucket_time, scaled_value ]
        elsif previous_value
          # No data in this bucket - maintain previous value
          [ bucket_time, previous_value ]
        else
          # No data and no previous value - skip this bucket
          nil
        end
      end.compact
    end
  end

  def generate_sum_series
    # Sum all child metric values for each time bucket
    combine_metric_series { |values| values.sum }
  end

  def generate_average_series
    # Average all child metric values for each time bucket
    combine_metric_series { |values| values.empty? ? 0 : values.sum.to_f / values.size }
  end

  def generate_difference_series
    # Take first metric's values and subtract all others
    return [] if child_metrics.empty?

    # If first_metric is specified, use it; otherwise use first child metric
    primary_metric = first_metric || child_metrics.first
    other_metrics = child_metrics.where.not(id: primary_metric.id)

    # Get series from primary and other metrics
    primary_series = primary_metric.series
    other_series = other_metrics.map(&:series)

    # Generate time buckets based on this metric's resolution
    time_buckets = generate_time_buckets

    time_buckets.map do |bucket_start|
      # Get primary metric value for this time bucket
      primary_value = primary_series.select { |time_key, value|
        time_key >= bucket_start && time_key < next_bucket_start(bucket_start)
      }.sum { |time_key, value| value }

      # Get sum of all other metrics for this time bucket
      other_values = other_series.map do |series|
        series.select { |time_key, value|
          time_key >= bucket_start && time_key < next_bucket_start(bucket_start)
        }.sum { |time_key, value| value }
      end

      difference_value = primary_value - other_values.sum
      [ bucket_start, difference_value ]
    end
  end

  def generate_count_series
    # Count non-zero values from child metrics for each time bucket
    combine_metric_series { |values| values.count { |v| v != 0 } }
  end


  def combine_metric_series(&block)
    return [] if child_metrics.empty?

    # Get series from all child metrics
    all_series = child_metrics.map(&:series)
    return [] if all_series.empty?

    # Generate time buckets based on this metric's resolution and time range
    time_buckets = generate_time_buckets

    # For each time bucket, combine values from all child metrics
    time_buckets.map do |bucket_start|
      values = all_series.map do |series|
        # Sum all values from child series that fall within this time bucket
        bucket_value = series.select { |time_key, value|
          time_key >= bucket_start && time_key < next_bucket_start(bucket_start)
        }.sum { |time_key, value| value }

        bucket_value
      end

      combined_value = block.call(values)
      [ bucket_start, combined_value ]
    end
  end

  def time_range
    case width
    when "daily"
      Time.current.beginning_of_day..Time.current
    when "weekly"
      Time.current.beginning_of_week(:saturday)..Time.current
    when "monthly"
      Time.current.beginning_of_month..Time.current
    when "90_days"
      90.days.ago.beginning_of_day..Time.current
    when "yearly"
      Time.current.beginning_of_year..Time.current
    when "7_days"
      7.days.ago.beginning_of_day..Time.current
    when "30_days"
      30.days.ago.beginning_of_day..Time.current
    when "all_time"
      actual_data_range
    end
  end

  def group_by_resolution(answers)
    answers.group_by do |answer|
      case resolution
      when "five_minute"
        answer.created_at.beginning_of_hour + (answer.created_at.min / 5) * 5.minutes
      when "hour"
        answer.created_at.beginning_of_hour
      when "day"
        answer.created_at.beginning_of_day
      when "week"
        answer.created_at.beginning_of_week
      when "month"
        answer.created_at.beginning_of_month
      end
    end
  end

  def numeric_value(answer)
    case answer.answer_type
    when "number", "range"
      answer.number_value || 0
    when "bool"
      answer.bool_value ? 1 : 0
    when "string"
      0 # Strings don't have numeric value for aggregation
    else
      0 # Default fallback for unknown answer types
    end
  end

  def generate_time_buckets
    range = time_range
    buckets = []
    current_time = bucket_start_for_time(range.begin)

    while current_time <= range.end
      buckets << current_time
      current_time = next_bucket_start(current_time)
    end

    buckets
  end

  def bucket_start_for_time(time)
    case resolution
    when "five_minute"
      time.beginning_of_hour + (time.min / 5) * 5.minutes
    when "hour"
      time.beginning_of_hour
    when "day"
      time.beginning_of_day
    when "week"
      time.beginning_of_week
    when "month"
      time.beginning_of_month
    end
  end

  def next_bucket_start(current_bucket)
    case resolution
    when "five_minute"
      current_bucket + 5.minutes
    when "hour"
      current_bucket + 1.hour
    when "day"
      current_bucket + 1.day
    when "week"
      current_bucket + 1.week
    when "month"
      current_bucket + 1.month
    end
  end

  def actual_data_range
    case function
    when "answer"
      # For answer metrics, get range from associated questions' answers
      if questions.any?
        answers = Answer.joins(:response, :question)
                        .where(questions: { id: questions.pluck(:id) })
                        .where(responses: { user_id: user_id })

        if answers.any?
          earliest = answers.minimum(:created_at)
          latest = answers.maximum(:created_at)
          earliest..latest
        else
          # If no answers found, return a reasonable default range
          1.year.ago..Time.current
        end
      else
        # If no questions, return a reasonable default range
        1.year.ago..Time.current
      end
    else
      # For calculated metrics, get range from child metrics
      if child_metrics.any?
        child_ranges = child_metrics.map { |child| child.send(:actual_data_range) }
        earliest = child_ranges.map(&:begin).min
        latest = child_ranges.map(&:end).max
        earliest..latest
      else
        # If no child metrics, return a reasonable default range
        1.year.ago..Time.current
      end
    end
  end

  private

  def store_child_metric_ids
    # child_metric_ids_temp is already set by the setter
  end

  def create_child_associations
    return unless @child_metric_ids_changed

    # Clear existing associations
    child_metric_metrics.destroy_all

    # Create new associations if any
    if @child_metric_ids_temp.present?
      @child_metric_ids_temp.each do |child_id|
        child_metric_metrics.create!(child_metric_id: child_id)
      end
    end
  end
end
