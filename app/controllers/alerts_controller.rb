class AlertsController < ApplicationController
  include NamespaceBrowsing

  before_action :require_login
  before_action :find_alert, only: [ :show, :edit, :update, :soft_delete ]

  def index
    setup_namespace_browsing(Alert, :alerts_path)
    @items = Alert.items_in_namespace(current_user, @current_namespace).not_deleted.includes(:metric)
  end

  def show
  end

  def new
    @alert = Alert.new
    @metrics = current_user.metrics.not_deleted
  end

  def create
    @alert = current_user.alerts.build(alert_params)

    if @alert.save
      redirect_to @alert, notice: "Alert created successfully"
    else
      @metrics = current_user.metrics.not_deleted
      render :new
    end
  end

  def edit
    @metrics = current_user.metrics.not_deleted
  end

  def update
    if @alert.update(alert_params)
      redirect_to @alert, notice: "Alert updated successfully"
    else
      @metrics = current_user.metrics.not_deleted
      render :edit
    end
  end

  def soft_delete
    @alert.soft_delete!
    redirect_to alerts_path, notice: "Alert deleted successfully"
  end

  private

  def find_alert
    @alert = current_user.alerts.not_deleted.find(params[:id])
  end

  def alert_params
    params.require(:alert).permit(:name, :metric_id, :threshold, :direction, :namespace, :delay, :message)
  end
end
