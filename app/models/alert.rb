class Alert < ApplicationRecord
  include Namespaceable
  
  belongs_to :user
  belongs_to :metric
  
  validates :name, presence: true
  validates :threshold, presence: true, numericality: true
  validates :direction, presence: true, inclusion: { in: %w[above below] }
  
  scope :not_deleted, -> { where(deleted: false) }
  
  def soft_delete!
    update!(deleted: true)
  end
  
  def activated?
    return false unless metric&.series&.any?
    
    # Get the most recent value from the metric series
    most_recent_value = metric.series.last&.last
    return false if most_recent_value.nil?
    
    case direction
    when 'above'
      most_recent_value > threshold
    when 'below'
      most_recent_value < threshold
    else
      false
    end
  end
  
  def status_color
    activated? ? 'red' : 'green'
  end
  
  def status_text
    activated? ? 'Activated' : 'Deactivated'
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
