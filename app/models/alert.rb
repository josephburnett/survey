class Alert < ApplicationRecord
  include Namespaceable

  belongs_to :user
  belongs_to :metric

  has_many :report_alerts, dependent: :destroy
  has_many :reports, through: :report_alerts

  validates :name, presence: true
  validates :threshold, presence: true, numericality: true
  validates :direction, presence: true, inclusion: { in: %w[above below] }
  validates :delay, presence: true, numericality: { greater_than: 0, only_integer: true }

  scope :not_deleted, -> { where(deleted: false) }

  def soft_delete!
    update!(deleted: true)
  end

  def activated?
    return false unless metric&.series&.any?

    series_data = metric.series
    return false if series_data.length < delay

    # Get the last 'delay' number of data points
    recent_values = series_data.last(delay).map(&:last)
    return false if recent_values.any?(&:nil?)

    # Check if ALL recent values are outside the threshold (activation condition)
    # OR if ANY recent value is inside the threshold (deactivation condition)
    case direction
    when "above"
      # For activation: all values must be above threshold
      # For deactivation: any value below or equal to threshold deactivates
      recent_values.all? { |value| value > threshold }
    when "below"
      # For activation: all values must be below threshold
      # For deactivation: any value above or equal to threshold deactivates
      recent_values.all? { |value| value < threshold }
    else
      false
    end
  end

  def status_color
    activated? ? "red" : "green"
  end

  def status_text
    activated? ? "Activated" : "Deactivated"
  end

  def display_name
    if name.present?
      name
    else
      id_display = id ? "##{id}" : "(New)"
      "Alert #{id_display}"
    end
  end

  def display_title
    "#{metric.display_name}: #{display_name}"
  end
end
