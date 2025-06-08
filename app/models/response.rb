class Response < ApplicationRecord
  belongs_to :section
  belongs_to :user, optional: true
  has_many :answers
end
