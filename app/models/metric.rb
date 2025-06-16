class Metric < ApplicationRecord
  belongs_to :user
  
  # Many-to-many relationships
  has_many :metric_questions, dependent: :destroy
  has_many :questions, through: :metric_questions
  
  has_many :parent_metric_metrics, class_name: 'MetricMetric', foreign_key: 'child_metric_id', dependent: :destroy
  has_many :parent_metrics, through: :parent_metric_metrics, source: :parent_metric
  
  has_many :child_metric_metrics, class_name: 'MetricMetric', foreign_key: 'parent_metric_id', dependent: :destroy
  has_many :child_metrics, through: :child_metric_metrics, source: :child_metric
  
  validates :resolution, presence: true, inclusion: { in: %w[day week month] }
  validates :width, presence: true, inclusion: { in: %w[daily weekly monthly 90_days yearly all_time] }
  validates :function, presence: true, inclusion: { in: %w[answer sum average difference count] }
  
  scope :not_deleted, -> { where(deleted: false) }
  
  def soft_delete!
    update!(deleted: true)
  end
  
  def type
    case function
    when 'answer'
      # Return the most common question type from referenced questions
      question_types = questions.pluck(:question_type).uniq
      question_types.first || 'number'
    else
      'number' # All calculated metrics return numbers
    end
  end
  
  def series
    case function
    when 'answer'
      generate_answer_series
    when 'sum'
      generate_sum_series
    when 'average'
      generate_average_series
    when 'difference'
      generate_difference_series
    when 'count'
      generate_count_series
    end
  end
  
  private
  
  def generate_answer_series
    # Get all answers to the referenced questions
    filtered_answers = Answer.joins(:response, :question)
                             .where(questions: { id: questions.pluck(:id) })
                             .where(responses: { user_id: user.id })
                             .where(created_at: time_range)
                             .order(:created_at)
    
    grouped_answers = group_by_resolution(filtered_answers)
    
    grouped_answers.map do |time_key, group_answers|
      # For answer function, sum within buckets
      values = group_answers.map { |answer| numeric_value(answer) }
      value = values.sum
      
      [time_key, value]
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
    combine_metric_series do |values|
      return 0 if values.empty?
      values.first - values[1..-1].sum
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
    
    # Get all unique time keys
    all_time_keys = all_series.flat_map { |series| series.map(&:first) }.uniq.sort
    
    # For each time bucket, combine values from all child metrics
    all_time_keys.map do |time_key|
      values = all_series.map do |series|
        time_value_pair = series.find { |pair| pair.first == time_key }
        time_value_pair ? time_value_pair.last : 0
      end
      
      combined_value = block.call(values)
      [time_key, combined_value]
    end
  end
  
  def time_range
    case width
    when 'daily'
      1.day.ago..Time.current
    when 'weekly'
      1.week.ago..Time.current
    when 'monthly'
      1.month.ago..Time.current
    when '90_days'
      90.days.ago..Time.current
    when 'yearly'
      1.year.ago..Time.current
    when 'all_time'
      Time.at(0)..Time.current
    end
  end
  
  def group_by_resolution(answers)
    answers.group_by do |answer|
      case resolution
      when 'day'
        answer.created_at.beginning_of_day
      when 'week'
        answer.created_at.beginning_of_week
      when 'month'
        answer.created_at.beginning_of_month
      end
    end
  end
  
  def numeric_value(answer)
    case answer.answer_type
    when 'number', 'range'
      answer.number_value || 0
    when 'bool'
      answer.bool_value ? 1 : 0
    when 'string'
      0 # Strings don't have numeric value for aggregation
    end
  end
  
  def display_name
    id_display = id ? "(ID: #{id})" : "(New)"
    "#{function&.capitalize || 'Unknown'} - #{resolution}/#{width} #{id_display}"
  end
end
