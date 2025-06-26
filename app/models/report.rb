class Report < ApplicationRecord
  include Namespaceable
  
  belongs_to :user
  
  # JSON attributes
  attribute :interval_config, :json
  
  # Many-to-many relationships
  has_many :report_alerts, dependent: :destroy
  has_many :alerts, through: :report_alerts
  
  has_many :report_metrics, dependent: :destroy
  has_many :metrics, through: :report_metrics
  
  validates :name, presence: true
  validates :time_of_day, presence: true
  validates :interval_type, presence: true, inclusion: { in: %w[weekly monthly] }
  validates :interval_config, presence: true
  
  validate :validate_interval_config
  
  scope :not_deleted, -> { where(deleted: false) }
  
  def soft_delete!
    update!(deleted: true)
  end
  
  # Class method to send all due reports
  def self.send_due_reports!
    Report.not_deleted.find_each do |report|
      if report.should_send_now?
        begin
          ReportMailer.scheduled_report(report).deliver_now
          report.update!(last_sent_at: Time.current)
          Rails.logger.info "Sent report: #{report.name} (ID: #{report.id})"
        rescue => e
          Rails.logger.error "Failed to send report #{report.name} (ID: #{report.id}): #{e.message}"
        end
      end
    end
  end
  
  # Check if this report should be sent now
  def should_send_now?
    return false unless next_send_time_passed?
    return false unless has_content_to_send?
    true
  end
  
  # Get active alerts for this report
  def active_alerts
    alerts.select(&:activated?)
  end
  
  # Check if report has content to send
  def has_content_to_send?
    # Has active alerts OR has metrics
    active_alerts.any? || metrics.any?
  end
  
  # Get next scheduled send time
  def next_send_time
    return nil unless time_of_day && interval_type && interval_config
    
    base_time = Time.current.beginning_of_day + time_of_day.seconds_since_midnight.seconds
    
    case interval_type
    when 'weekly'
      days = interval_config['days'] || []
      return nil if days.empty?
      
      # Find next occurrence
      (0..7).each do |days_ahead|
        candidate_time = base_time + days_ahead.days
        if days.include?(candidate_time.strftime('%A').downcase) && candidate_time > Time.current
          return candidate_time
        end
      end
      
    when 'monthly'
      day_of_month = interval_config['day_of_month']&.to_i
      return nil unless day_of_month
      
      # This month if not past
      candidate_time = base_time.change(day: day_of_month)
      return candidate_time if candidate_time > Time.current
      
      # Next month
      return candidate_time + 1.month
    end
    
    nil
  end
  
  private
  
  def next_send_time_passed?
    return true unless last_sent_at
    return false unless next_send_time
    Time.current >= next_send_time
  end
  
  def validate_interval_config
    return unless interval_type
    
    if interval_config.blank?
      errors.add(:interval_config, 'cannot be blank')
      return
    end
    
    case interval_type
    when 'weekly'
      days = interval_config['days']
      if days.blank? || !days.is_a?(Array) || days.empty?
        errors.add(:interval_config, 'must include at least one day of the week for weekly interval')
      elsif !days.all? { |day| %w[monday tuesday wednesday thursday friday saturday sunday].include?(day) }
        errors.add(:interval_config, 'must include valid days of the week for weekly interval')
      end
    when 'monthly'
      day = interval_config['day_of_month']&.to_i
      unless day && day >= 1 && day <= 31
        errors.add(:interval_config, 'must include valid day of month (1-31) for monthly interval')
      end
    end
  end
end
