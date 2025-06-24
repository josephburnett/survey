namespace :reports do
  desc "Send all due reports"
  task send_due: :environment do
    puts "Checking for due reports..."
    
    Report.not_deleted.find_each do |report|
      if report.should_send_now?
        puts "  - Sending report: #{report.name}"
        begin
          ReportMailer.scheduled_report(report).deliver_now
          report.update!(last_sent_at: Time.current)
          puts "    ✓ Sent successfully"
        rescue => e
          puts "    ✗ Failed: #{e.message}"
        end
      else
        puts "  - Skipping report: #{report.name} (not due or no content)"
      end
    end
    
    puts "Done!"
  end
  
  desc "Test report email (requires REPORT_ID environment variable)"
  task test_email: :environment do
    report_id = ENV['REPORT_ID']
    unless report_id
      puts "Usage: REPORT_ID=1 rails reports:test_email"
      exit 1
    end
    
    report = Report.find(report_id)
    puts "Sending test email for report: #{report.name}"
    
    ReportMailer.scheduled_report(report).deliver_now
    puts "Test email sent!"
  end
  
  desc "Show report schedules"
  task schedule: :environment do
    puts "Report Schedules:"
    puts "=================="
    
    Report.not_deleted.find_each do |report|
      puts "#{report.name}:"
      puts "  - Next send: #{report.next_send_time || 'Not scheduled'}"
      puts "  - Last sent: #{report.last_sent_at || 'Never'}"
      puts "  - Has content: #{report.has_content_to_send? ? 'Yes' : 'No'}"
      puts "  - Should send now: #{report.should_send_now? ? 'Yes' : 'No'}"
      puts ""
    end
  end
end