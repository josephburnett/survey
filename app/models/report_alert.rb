class ReportAlert < ApplicationRecord
  belongs_to :report
  belongs_to :alert
end
