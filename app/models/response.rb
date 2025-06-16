class Response < ApplicationRecord
  belongs_to :form
  belongs_to :user, optional: true
  has_many :answers
  
  scope :not_deleted, -> { where(deleted: false) }
  
  def soft_delete!
    transaction do
      answers.not_deleted.each(&:soft_delete!)
      update!(deleted: true)
    end
  end
end
