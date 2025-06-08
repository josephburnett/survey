class Section < ApplicationRecord
  validates :name, presence: true
  validates :prompt, presence: true
  
  belongs_to :user, optional: true
  has_and_belongs_to_many :questions
  has_many :responses
end
