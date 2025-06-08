class Answer < ApplicationRecord
  belongs_to :question
  
  validates :answer_type, presence: true, inclusion: { in: %w[string number bool range] }
  validates :string_value, presence: true, if: -> { answer_type == 'string' }
  validates :number_value, presence: true, if: -> { answer_type == 'number' }
  validates :bool_value, inclusion: { in: [true, false] }, if: -> { answer_type == 'bool' }
  validates :range_min, :range_max, presence: true, if: -> { answer_type == 'range' }
  validate :range_min_less_than_max, if: -> { answer_type == 'range' }
  
  def value
    case answer_type
    when 'string'
      string_value
    when 'number'
      number_value
    when 'bool'
      bool_value
    when 'range'
      [range_min, range_max]
    end
  end
  
  def value=(val)
    case answer_type
    when 'string'
      self.string_value = val
    when 'number'
      self.number_value = val
    when 'bool'
      self.bool_value = val
    when 'range'
      self.range_min, self.range_max = val
    end
  end
  
  private
  
  def range_min_less_than_max
    return unless range_min && range_max
    errors.add(:range_max, 'must be greater than range_min') if range_max <= range_min
  end
end
