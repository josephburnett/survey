class Response < ApplicationRecord
  belongs_to :section
  has_many :answers
end
