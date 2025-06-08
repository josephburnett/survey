class Response < ApplicationRecord
  belongs_to :section
  belongs_to :user, optional: true
  has_many :answers
  
  scope :not_deleted, -> { where(deleted: false) }
  
  def soft_delete!
    update!(deleted: true)
  end
end
