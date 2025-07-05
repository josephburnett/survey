class MetricsController < ApplicationController
  include NamespaceBrowsing

  before_action :require_login
  before_action :find_metric, only: [ :show, :edit, :update, :soft_delete ]

  def index
    setup_namespace_browsing(Metric, :metrics_path)
    @items = Metric.items_in_namespace(current_user, @current_namespace).not_deleted
  end

  def show
    @series_data = limit_series_data(@metric.series)
  end

  def new
    @metric = Metric.new
    @questions = current_user.questions.not_deleted
    @metrics = current_user.metrics.not_deleted
  end

  def create
    @metric = current_user.metrics.build(metric_params)

    if @metric.save
      redirect_to @metric, notice: "Metric created successfully"
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
      redirect_to @metric, notice: "Metric updated successfully"
    else
      @questions = current_user.questions.not_deleted
      @metrics = current_user.metrics.not_deleted.where.not(id: @metric.id)
      render :edit
    end
  end

  def soft_delete
    @metric.soft_delete!
    redirect_to metrics_path, notice: "Metric deleted successfully"
  end

  private

  def find_metric
    @metric = current_user.metrics.not_deleted.includes(:questions, :child_metric_metrics, :parent_metrics, :first_metric).find(params[:id])
  end

  def limit_series_data(series)
    case @metric.width
    when "daily"
      series.last((1.2 * 1).ceil)  # 1 day * 1.2 = ~2 points
    when "weekly"
      series.last((1.2 * 7).ceil)  # 7 days * 1.2 = ~9 points
    when "monthly"
      series.last((1.2 * 30).ceil)  # 30 days * 1.2 = ~36 points
    when "7_days"
      series.last((1.2 * 7).ceil)  # 7 days * 1.2 = ~9 points
    when "30_days"
      series.last((1.2 * 30).ceil)  # 30 days * 1.2 = ~36 points
    when "90_days"
      series.last((1.2 * 90).ceil)  # 90 days * 1.2 = ~108 points
    when "yearly"
      series.last((1.2 * 365).ceil)  # 365 days * 1.2 = ~438 points
    when "all_time"
      series  # Load everything for all_time, even if it takes a long time
    else
      series.last(100)  # Fallback for unknown width values
    end
  end

  def metric_params
    params.require(:metric).permit(:name, :function, :resolution, :width, :wrap, :scale, :first_metric_id, :namespace, question_ids: [], child_metric_ids: [])
  end
end
