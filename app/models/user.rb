class User < ApplicationRecord
  has_secure_password
  
  validates :name, presence: true, uniqueness: true
  
  has_many :forms
  has_many :questions
  has_many :sections
  has_many :answers
  has_many :responses
  has_many :metrics
  has_many :dashboards
end
