class Dashboard < ApplicationRecord
  include Namespaceable
  
  belongs_to :user
  
  has_many :dashboard_metrics, dependent: :destroy
  has_many :metrics, through: :dashboard_metrics
  
  validates :name, presence: true
  
  scope :not_deleted, -> { where(deleted: false) }
  
  def soft_delete!
    update!(deleted: true)
  end
end
