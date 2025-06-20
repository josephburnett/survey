class DashboardsController < ApplicationController
  before_action :require_login
  before_action :find_dashboard, only: [:show, :edit, :update, :soft_delete]
  
  def index
    @dashboards = current_user.dashboards.not_deleted
  end

  def show
  end
  
  def new
    @dashboard = Dashboard.new
    @metrics = current_user.metrics.not_deleted
  end
  
  def create
    @dashboard = current_user.dashboards.build(dashboard_params)
    
    if @dashboard.save
      redirect_to @dashboard, notice: 'Dashboard created successfully'
    else
      @metrics = current_user.metrics.not_deleted
      render :new
    end
  end
  
  def edit
    @metrics = current_user.metrics.not_deleted
  end
  
  def update
    if @dashboard.update(dashboard_params)
      redirect_to @dashboard, notice: 'Dashboard updated successfully'
    else
      @metrics = current_user.metrics.not_deleted
      render :edit
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
    params.require(:dashboard).permit(:name, metric_ids: [])
  end
end