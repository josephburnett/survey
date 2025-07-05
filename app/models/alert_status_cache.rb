class AlertStatusCache < ApplicationRecord
  belongs_to :alert

  scope :fresh, -> { where("calculated_at > ?", 1.hour.ago) }

  def fresh?
    calculated_at && calculated_at > alert.updated_at && calculated_at > 1.hour.ago
  end

  def self.update_for_alert(alert)
    is_activated, current_value = alert.calculate_status_uncached
    cache_record = find_or_initialize_by(alert: alert)
    cache_record.update!(
      is_activated: is_activated,
      current_value: current_value,
      calculated_at: Time.current
    )
    cache_record
  end
end
