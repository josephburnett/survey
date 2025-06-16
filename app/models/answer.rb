class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :response, optional: true
  belongs_to :user, optional: true
  
  # Reverse association to see which metrics reference this answer
  has_many :metric_answers, dependent: :destroy
  has_many :metrics, through: :metric_answers
  
  validates :answer_type, presence: true, inclusion: { in: %w[string number bool range] }
  validates :string_value, presence: true, if: -> { answer_type == 'string' }
  validates :number_value, presence: true, if: -> { answer_type == 'number' || answer_type == 'range' }
  validates :bool_value, inclusion: { in: [true, false] }, if: -> { answer_type == 'bool' }
  
  scope :not_deleted, -> { where(deleted: false) }
  
  def soft_delete!
    update!(deleted: true)
  end
  
  def value
    case answer_type
    when 'string'
      string_value
    when 'number', 'range'
      number_value
    when 'bool'
      bool_value
    end
  end
  
  def value=(val)
    case answer_type
    when 'string'
      self.string_value = val
    when 'number', 'range'
      self.number_value = val
    when 'bool'
      self.bool_value = val
    end
  end
  
  def display_name
    "#{question.name}: #{value} (#{created_at.strftime('%Y-%m-%d')})"
  end
end
