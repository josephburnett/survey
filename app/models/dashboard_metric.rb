class DashboardMetric < ApplicationRecord
  belongs_to :dashboard
  belongs_to :metric

  validates :dashboard_id, uniqueness: { scope: :metric_id }

  scope :ordered, -> { order(:position) }
end
