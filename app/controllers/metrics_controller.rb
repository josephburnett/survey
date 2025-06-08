class MetricsController < ApplicationController
  before_action :require_login
  before_action :find_metric, only: [:show, :edit, :update, :soft_delete]
  
  def index
    @metrics = current_user.metrics.not_deleted
  end

  def show
    @series_data = @metric.series
  end
  
  def new
    @metric = Metric.new
    @questions = current_user.questions.not_deleted
    @metrics = current_user.metrics.not_deleted
  end
  
  def create
    @metric = current_user.metrics.build(metric_params)
    
    if @metric.save
      redirect_to @metric, notice: 'Metric created successfully'
    else
      @questions = current_user.questions.not_deleted
      @metrics = current_user.metrics.not_deleted
      render :new
    end
  end
  
  def edit
    @questions = current_user.questions.not_deleted
    @metrics = current_user.metrics.not_deleted.where.not(id: @metric.id)
  end
  
  def update
    if @metric.update(metric_params)
      redirect_to @metric, notice: 'Metric updated successfully'
    else
      @questions = current_user.questions.not_deleted
      @metrics = current_user.metrics.not_deleted.where.not(id: @metric.id)
      render :edit
    end
  end
  
  def soft_delete
    @metric.soft_delete!
    redirect_to metrics_path, notice: 'Metric deleted successfully'
  end
  
  private
  
  def find_metric
    @metric = current_user.metrics.not_deleted.find(params[:id])
  end
  
  def metric_params
    params.require(:metric).permit(:source_type, :source_id, :resolution, :width, :aggregation)
  end
end
