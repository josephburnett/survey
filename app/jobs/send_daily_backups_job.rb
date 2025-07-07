class SendDailyBackupsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting daily backup process..."

    # Find all users with backup enabled
    users_with_backups = User.joins(:user_setting)
                             .where(user_settings: { backup_enabled: true })
                             .where.not(user_settings: { backup_email: [ nil, "" ] })
                             .where.not(user_settings: { encryption_key: [ nil, "" ] })

    Rails.logger.info "Found #{users_with_backups.count} user(s) with backups enabled"

    users_with_backups.find_each do |user|
      begin
        Rails.logger.info "Sending backup for user: #{user.name} (#{user.email})"
        BackupMailer.daily_backup(user).deliver_now
        Rails.logger.info "Backup sent successfully to #{user.user_setting.backup_email}"
      rescue => e
        Rails.logger.error "Failed to send backup for #{user.name}: #{e.message}"
        raise e
      end
    end

    Rails.logger.info "Daily backup process completed"
  end
end
