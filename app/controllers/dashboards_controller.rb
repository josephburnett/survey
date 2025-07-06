class DashboardsController < ApplicationController
  include NamespaceBrowsing
  before_action :require_login
  before_action :find_dashboard, only: [ :show, :edit, :update, :soft_delete, :answer_question, :refresh_cache ]

  def index
    setup_namespace_browsing(Dashboard, :dashboards_path)
    @items = Dashboard.items_in_namespace(current_user, @current_namespace).not_deleted
  end

  def show
    # Pre-calculation strategy allows real-time dashboard functionality
  end

  def new
    @dashboard = Dashboard.new
    current_ns = params[:namespace] || ""
    @metrics = entities_in_allowed_namespaces(Metric, current_ns)
    @questions = entities_in_allowed_namespaces(Question, current_ns)
    @forms = entities_in_allowed_namespaces(Form, current_ns)
    @dashboards = entities_in_allowed_namespaces(Dashboard, current_ns)
    @alerts = entities_in_allowed_namespaces(Alert, current_ns)
  end

  def create
    @dashboard = current_user.dashboards.build(dashboard_params)

    if @dashboard.save
      redirect_to @dashboard, notice: "Dashboard created successfully"
    else
      current_ns = @dashboard.namespace || ""
      @metrics = entities_in_allowed_namespaces(Metric, current_ns)
      @questions = entities_in_allowed_namespaces(Question, current_ns)
      @forms = entities_in_allowed_namespaces(Form, current_ns)
      @dashboards = entities_in_allowed_namespaces(Dashboard, current_ns)
      @alerts = entities_in_allowed_namespaces(Alert, current_ns)
      render :new
    end
  end

  def edit
    @metrics = entities_in_allowed_namespaces(Metric, @dashboard.namespace)
    @questions = entities_in_allowed_namespaces(Question, @dashboard.namespace)
    @forms = entities_in_allowed_namespaces(Form, @dashboard.namespace)
    @dashboards = entities_in_allowed_namespaces(Dashboard, @dashboard.namespace).where.not(id: @dashboard.id)
    @alerts = entities_in_allowed_namespaces(Alert, @dashboard.namespace)
  end

  def update
    if @dashboard.update(dashboard_params)
      redirect_to @dashboard, notice: "Dashboard updated successfully"
    else
      @metrics = entities_in_allowed_namespaces(Metric, @dashboard.namespace)
      @questions = entities_in_allowed_namespaces(Question, @dashboard.namespace)
      @forms = entities_in_allowed_namespaces(Form, @dashboard.namespace)
      @dashboards = entities_in_allowed_namespaces(Dashboard, @dashboard.namespace).where.not(id: @dashboard.id)
      @alerts = entities_in_allowed_namespaces(Alert, @dashboard.namespace)
      render :edit
    end
  end

  def answer_question
    question = current_user.questions.find(params[:question_id])

    answer = Answer.new(
      question: question,
      user: current_user,
      answer_type: question.question_type,
      namespace: question.namespace
    )

    # Set the appropriate value based on question type
    case question.question_type
    when "string"
      answer.string_value = params[:answer_value]
    when "number"
      answer.number_value = params[:answer_value].to_f
    when "bool"
      answer.bool_value = params[:answer_value] == "1"
    when "range"
      answer.number_value = params[:answer_value].to_f
    end

    if answer.save
      redirect_to @dashboard, notice: "Answer submitted successfully"
    else
      redirect_to @dashboard, alert: "Error submitting answer"
    end
  end

  def soft_delete
    @dashboard.soft_delete!
    redirect_to dashboards_path, notice: "Dashboard deleted successfully"
  end

  def refresh_cache
    # Clear caches for all metrics and alerts in the dashboard
    @dashboard.all_items.each do |dashboard_item|
      case dashboard_item[:type]
      when "metric"
        metric = dashboard_item[:item]
        metric.metric_series_cache&.destroy
        # Also clear alert caches for alerts using this metric
        metric.alerts.each { |alert| alert.alert_status_cache&.destroy }
      when "alert"
        alert = dashboard_item[:item]
        alert.alert_status_cache&.destroy
        alert.metric.metric_series_cache&.destroy
      end
    end

    redirect_to @dashboard, notice: "Cache refreshed successfully"
  end

  private

  def find_dashboard
    # Minimal loading for performance - avoid loading associations that trigger expensive calculations
    @dashboard = current_user.dashboards.not_deleted.find(params[:id])
  end

  def dashboard_params
    params.require(:dashboard).permit(:name, :namespace, metric_ids: [], question_ids: [], form_ids: [], linked_dashboard_ids: [], alert_ids: [])
  end
end
