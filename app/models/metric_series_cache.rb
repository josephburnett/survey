class MetricSeriesCache < ApplicationRecord
  belongs_to :metric

  scope :fresh, -> { where("calculated_at > ?", 1.hour.ago) }

  def fresh?
    calculated_at && calculated_at > metric.updated_at && calculated_at > 1.hour.ago
  end

  def self.update_for_metric(metric)
    series_data = metric.calculate_series_uncached
    cache_record = find_or_initialize_by(metric: metric)
    cache_record.update!(
      series_data: series_data,
      calculated_at: Time.current
    )
    cache_record
  end
end