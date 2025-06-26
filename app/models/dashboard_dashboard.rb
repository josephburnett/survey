class DashboardDashboard < ApplicationRecord
  belongs_to :dashboard
  belongs_to :linked_dashboard, class_name: "Dashboard"

  validates :dashboard_id, uniqueness: { scope: :linked_dashboard_id }
  validate :cannot_link_to_self

  scope :ordered, -> { order(:position) }

  private

  def cannot_link_to_self
    errors.add(:linked_dashboard, "cannot link to itself") if dashboard_id == linked_dashboard_id
  end
end
