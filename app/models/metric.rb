class Metric < ApplicationRecord
  belongs_to :user
  belongs_to :source, polymorphic: true
  
  validates :resolution, presence: true, inclusion: { in: %w[day week month] }
  validates :width, presence: true, inclusion: { in: %w[daily weekly monthly 90_days yearly all_time] }
  validates :aggregation, presence: true, inclusion: { in: %w[sum average] }
  
  def type
    case source
    when Question
      source.question_type
    when Metric
      source.type
    end
  end
  
  def series
    case source
    when Question
      generate_question_series
    when Metric
      generate_metric_series
    end
  end
  
  private
  
  def generate_question_series
    answers = source.answers.joins(:response)
                    .where(responses: { user_id: user.id })
                    .where(created_at: time_range)
                    .order(:created_at)
    
    grouped_answers = group_by_resolution(answers)
    
    grouped_answers.map do |time_key, group_answers|
      value = case aggregation
              when 'sum'
                group_answers.sum { |answer| numeric_value(answer) }
              when 'average'
                values = group_answers.map { |answer| numeric_value(answer) }
                values.empty? ? 0 : values.sum.to_f / values.size
              end
      
      [time_key, value]
    end
  end
  
  def generate_metric_series
    # For metrics sourced from other metrics, delegate to the source metric
    source.series
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
end
