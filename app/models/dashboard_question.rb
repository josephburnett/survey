class DashboardQuestion < ApplicationRecord
  belongs_to :dashboard
  belongs_to :question
  
  validates :dashboard_id, uniqueness: { scope: :question_id }
  
  scope :ordered, -> { order(:position) }
end