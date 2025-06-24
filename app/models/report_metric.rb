class ReportMetric < ApplicationRecord
  belongs_to :report
  belongs_to :metric
end
