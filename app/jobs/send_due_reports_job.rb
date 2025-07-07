class SendDueReportsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Checking for due reports..."

    Report.not_deleted.find_each do |report|
      Rails.logger.info "Checking report: #{report.name}"
      Rails.logger.info "  - has_content_to_send?: #{report.has_content_to_send?}"
      Rails.logger.info "  - next_send_time: #{report.next_send_time}"
      Rails.logger.info "  - last_sent_at: #{report.last_sent_at}"
      Rails.logger.info "  - should_send_now?: #{report.should_send_now?}"

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
        Rails.logger.info "Skipping report: #{report.name} (not due or no content)"
      end
    end

    Rails.logger.info "Finished checking for due reports"
  end
end
