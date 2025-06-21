class DashboardsController < ApplicationController
  include NamespaceBrowsing
  before_action :require_login
  before_action :find_dashboard, only: [:show, :edit, :update, :soft_delete, :answer_question]
  
  def index
    setup_namespace_browsing(Dashboard, :dashboards_path)
    @items = Dashboard.items_in_namespace(current_user, @current_namespace).not_deleted
  end

  def show
  end
  
  def new
    @dashboard = Dashboard.new
    # For new dashboards, show all entities since namespace isn't set yet
    @metrics = current_user.metrics.not_deleted
    @questions = current_user.questions.not_deleted
    @forms = current_user.forms.not_deleted
    @dashboards = current_user.dashboards.not_deleted.where.not(id: nil) # All other dashboards
    @alerts = current_user.alerts.not_deleted
  end
  
  def create
    @dashboard = current_user.dashboards.build(dashboard_params)
    
    if @dashboard.save
      redirect_to @dashboard, notice: 'Dashboard created successfully'
    else
      @metrics = current_user.metrics.not_deleted
      @questions = current_user.questions.not_deleted
      @forms = current_user.forms.not_deleted
      @dashboards = current_user.dashboards.not_deleted.where.not(id: nil)
      @alerts = current_user.alerts.not_deleted
      render :new
    end
  end
  
  def edit
    # Filter entities to only show those in the same namespace as the dashboard
    namespace = @dashboard.namespace
    @metrics = current_user.metrics.not_deleted.where(namespace: namespace)
    @questions = current_user.questions.not_deleted.where(namespace: namespace)
    @forms = current_user.forms.not_deleted.where(namespace: namespace)
    @dashboards = current_user.dashboards.not_deleted.where(namespace: namespace).where.not(id: @dashboard.id)
    @alerts = current_user.alerts.not_deleted.where(namespace: namespace)
  end
  
  def update
    if @dashboard.update(dashboard_params)
      redirect_to @dashboard, notice: 'Dashboard updated successfully'
    else
      # Filter entities to only show those in the same namespace as the dashboard
      namespace = @dashboard.namespace
      @metrics = current_user.metrics.not_deleted.where(namespace: namespace)
      @questions = current_user.questions.not_deleted.where(namespace: namespace)
      @forms = current_user.forms.not_deleted.where(namespace: namespace)
      @dashboards = current_user.dashboards.not_deleted.where(namespace: namespace).where.not(id: @dashboard.id)
      @alerts = current_user.alerts.not_deleted.where(namespace: namespace)
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
    when 'string'
      answer.string_value = params[:answer_value]
    when 'number'
      answer.number_value = params[:answer_value].to_f
    when 'bool'
      answer.bool_value = params[:answer_value] == '1'
    when 'range'
      answer.number_value = params[:answer_value].to_f
    end
    
    if answer.save
      redirect_to @dashboard, notice: 'Answer submitted successfully'
    else
      redirect_to @dashboard, alert: 'Error submitting answer'
    end
  end
  
  def soft_delete
    @dashboard.soft_delete!
    redirect_to dashboards_path, notice: 'Dashboard deleted successfully'
  end
  
  private
  
  def find_dashboard
    @dashboard = current_user.dashboards.not_deleted.find(params[:id])
  end
  
  def dashboard_params
    params.require(:dashboard).permit(:name, :namespace, metric_ids: [], question_ids: [], form_ids: [], linked_dashboard_ids: [], alert_ids: [])
  end
end