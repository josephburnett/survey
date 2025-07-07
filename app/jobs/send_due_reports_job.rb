class SendDueReportsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Checking for due reports..."

    Report.not_deleted.find_each do |report|
      if report.should_send_now?
        Rails.logger.info "Sending report: #{report.name}"
        begin
          ReportMailer.scheduled_report(report).deliver_now
          report.update!(last_sent_at: Time.current)
          Rails.logger.info "Report #{report.name} sent successfully"
        rescue => e
          Rails.logger.error "Failed to send report #{report.name}: #{e.message}"
          raise e
        end
      else
        Rails.logger.debug "Skipping report: #{report.name} (not due or no content)"
      end
    end

    Rails.logger.info "Finished checking for due reports"
  end
end
