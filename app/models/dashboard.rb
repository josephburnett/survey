class Dashboard < ApplicationRecord
  include Namespaceable

  belongs_to :user

  # Metric associations
  has_many :dashboard_metrics, dependent: :destroy
  has_many :metrics, through: :dashboard_metrics

  # Question associations
  has_many :dashboard_questions, dependent: :destroy
  has_many :questions, through: :dashboard_questions

  # Form associations
  has_many :dashboard_forms, dependent: :destroy
  has_many :forms, through: :dashboard_forms

  # Dashboard associations (linking to other dashboards)
  has_many :dashboard_dashboards, dependent: :destroy
  has_many :linked_dashboards, through: :dashboard_dashboards

  # Alert associations
  has_many :dashboard_alerts, dependent: :destroy
  has_many :alerts, through: :dashboard_alerts

  validates :name, presence: true

  scope :not_deleted, -> { where(deleted: false) }

  def soft_delete!
    update!(deleted: true)
  end

  # Get all dashboard items in their display order
  def all_items
    items = []

    # Add metrics
    dashboard_metrics.ordered.includes(:metric).each do |dm|
      items << { type: "metric", item: dm.metric, position: dm.position }
    end

    # Add questions
    dashboard_questions.ordered.includes(:question).each do |dq|
      items << { type: "question", item: dq.question, position: dq.position }
    end

    # Add forms
    dashboard_forms.ordered.includes(:form).each do |df|
      items << { type: "form", item: df.form, position: df.position }
    end

    # Add linked dashboards
    dashboard_dashboards.ordered.includes(:linked_dashboard).each do |dd|
      items << { type: "dashboard", item: dd.linked_dashboard, position: dd.position }
    end

    # Add alerts
    dashboard_alerts.ordered.includes(:alert).each do |da|
      items << { type: "alert", item: da.alert, position: da.position }
    end

    # Sort by position
    items.sort_by { |item| item[:position] }
  end
end
