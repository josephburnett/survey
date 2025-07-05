class UserSetting < ApplicationRecord
  belongs_to :user

  validates :backup_method, inclusion: { in: %w[email] }, allow_nil: true
  validates :backup_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :backup_enabled?
  validates :encryption_key, presence: true, if: :backup_enabled?

  before_create :generate_encryption_key, if: :backup_enabled?

  private

  def generate_encryption_key
    self.encryption_key = SecureRandom.base64(32) # 256-bit key
  end
end
