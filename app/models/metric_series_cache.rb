class MetricSeriesCache < ApplicationRecord
  belongs_to :metric

  scope :fresh, -> { where("calculated_at > ?", 1.hour.ago) }

  def fresh?
    calculated_at && calculated_at > metric.updated_at && calculated_at > 1.hour.ago
  end

  def self.update_for_metric(metric)
    series_data = metric.calculate_series_uncached
    # Convert Time objects to ISO strings for JSON storage
    serialized_data = series_data.map do |time, value|
      [ time.iso8601, value ]
    end
    cache_record = find_or_initialize_by(metric: metric)
    cache_record.update!(
      series_data: serialized_data,
      calculated_at: Time.current
    )
    cache_record
  end

  def series_data
    # Convert ISO strings back to Time objects when retrieving
    raw_data = super
    return [] unless raw_data

    raw_data.map do |time_str, value|
      [ Time.parse(time_str), value ]
    end
  end
end
