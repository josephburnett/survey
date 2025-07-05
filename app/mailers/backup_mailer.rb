class BackupMailer < ApplicationMailer
  def daily_backup(user)
    @user = user
    @generated_at = Time.current
    
    # Generate the backup data
    backup_service = BackupService.new(user)
    backup_data = backup_service.generate_backup_data
    
    # Encrypt the backup
    encrypted_backup = backup_service.encrypt_backup(backup_data, user.user_setting.encryption_key)
    
    # Create the attachment
    filename = "routine_backup_#{@user.name.parameterize}_#{@generated_at.strftime('%Y%m%d')}.json.enc"
    attachments[filename] = {
      mime_type: 'application/json',
      content: encrypted_backup
    }
    
    mail(
      to: user.user_setting.backup_email,
      subject: "Daily Routine Backup - #{@generated_at.strftime('%B %d, %Y')}"
    )
  end
end