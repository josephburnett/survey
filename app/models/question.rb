class Question < ApplicationRecord
  validates :name, presence: true
  
  has_and_belongs_to_many :sections
  has_many :answers
end
