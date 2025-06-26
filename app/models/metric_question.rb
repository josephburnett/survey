class MetricQuestion < ApplicationRecord
  belongs_to :metric
  belongs_to :question
end
