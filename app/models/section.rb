class Section < ApplicationRecord
  validates :name, presence: true
  validates :prompt, presence: true
  
  has_and_belongs_to_many :questions
end
