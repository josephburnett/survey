class Form < ApplicationRecord
  validates :name, presence: true
  
  belongs_to :user, optional: true
  has_and_belongs_to_many :sections
  has_many :responses
  
  scope :not_deleted, -> { where(deleted: false) }
  
  def soft_delete!
    update!(deleted: true)
  end
end