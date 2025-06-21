class DashboardAlert < ApplicationRecord
  belongs_to :dashboard
  belongs_to :alert
  
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  scope :ordered, -> { order(:position) }
end