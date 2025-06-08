class MetricsController < ApplicationController
  before_action :require_login
  before_action :find_metric, only: [:show]
  
  def index
    @metrics = current_user.metrics
  end

  def show
    @series_data = @metric.series
  end
  
  private
  
  def find_metric
    @metric = current_user.metrics.find(params[:id])
  end
end
