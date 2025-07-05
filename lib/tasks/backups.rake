namespace :backups do
  desc "Send daily backups to users who have them enabled"
  task send_daily: :environment do
    puts "Starting daily backup process..."
    
    # Find all users with backup enabled
    users_with_backups = User.joins(:user_setting)
                              .where(user_settings: { backup_enabled: true })
                              .where.not(user_settings: { backup_email: [nil, ''] })
                              .where.not(user_settings: { encryption_key: [nil, ''] })
    
    puts "Found #{users_with_backups.count} user(s) with backups enabled"
    
    users_with_backups.find_each do |user|
      begin
        puts "  - Sending backup for user: #{user.name} (#{user.email})"
        BackupMailer.daily_backup(user).deliver_now
        puts "    ✓ Backup sent successfully to #{user.user_setting.backup_email}"
      rescue => e
        puts "    ✗ Failed to send backup for #{user.name}: #{e.message}"
        Rails.logger.error "Backup failed for user #{user.id}: #{e.message}"
      end
    end
    
    puts "Daily backup process completed"
  end

  desc "Test backup for a specific user (provide user_id as argument)"
  task :test_backup, [:user_id] => :environment do |t, args|
    user_id = args[:user_id]
    
    unless user_id
      puts "Usage: rake backups:test_backup[user_id]"
      exit 1
    end
    
    user = User.find(user_id)
    
    unless user.user_setting&.backup_enabled?
      puts "Backup is not enabled for user #{user.name}"
      exit 1
    end
    
    puts "Testing backup for user: #{user.name} (#{user.email})"
    
    begin
      BackupMailer.daily_backup(user).deliver_now
      puts "✓ Test backup sent successfully to #{user.user_setting.backup_email}"
    rescue => e
      puts "✗ Failed to send test backup: #{e.message}"
      exit 1
    end
  end
end