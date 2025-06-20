class DashboardForm < ApplicationRecord
  belongs_to :dashboard
  belongs_to :form
  
  validates :dashboard_id, uniqueness: { scope: :form_id }
  
  scope :ordered, -> { order(:position) }
end