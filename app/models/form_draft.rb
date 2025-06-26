class FormDraft < ApplicationRecord
  belongs_to :user
  belongs_to :form

  validates :user_id, uniqueness: { scope: :form_id }

  # Helper method to update draft data
  def update_field(field_id, value)
    self.draft_data ||= {}
    self.draft_data[field_id] = value
    save!
  end

  # Helper method to get field value
  def get_field(field_id)
    return nil unless draft_data
    draft_data[field_id]
  end
end
