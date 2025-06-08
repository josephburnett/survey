class Question < ApplicationRecord
  validates :name, presence: true
  
  belongs_to :user, optional: true
  has_and_belongs_to_many :sections
  has_many :answers
end
