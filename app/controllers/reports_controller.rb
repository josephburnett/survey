class ReportsController < ApplicationController
  include NamespaceBrowsing
  
  before_action :require_login
  before_action :find_report, only: [:show, :edit, :update, :soft_delete]
  
  def index
    setup_namespace_browsing(Report, :reports_path)
    @items = Report.items_in_namespace(current_user, @current_namespace).not_deleted
  end

  def show
  end

  def new
    @report = Report.new
    @alerts = current_user.alerts.not_deleted
    @metrics = current_user.metrics.not_deleted
  end

  def create
    @report = current_user.reports.build(report_params)
    
    if @report.save
      # Handle alert associations
      if params[:alert_ids].present?
        params[:alert_ids].each do |alert_id|
          @report.report_alerts.create(alert_id: alert_id) if alert_id.present?
        end
      end
      
      # Handle metric associations
      if params[:metric_ids].present?
        params[:metric_ids].each do |metric_id|
          @report.report_metrics.create(metric_id: metric_id) if metric_id.present?
        end
      end
      
      redirect_to @report, notice: 'Report created successfully'
    else
      @alerts = current_user.alerts.not_deleted
      @metrics = current_user.metrics.not_deleted
      render :new
    end
  end

  def edit
    @alerts = current_user.alerts.not_deleted
    @metrics = current_user.metrics.not_deleted
  end

  def update
    if @report.update(report_params)
      # Update alert associations
      @report.report_alerts.destroy_all
      if params[:alert_ids].present?
        params[:alert_ids].each do |alert_id|
          @report.report_alerts.create(alert_id: alert_id) if alert_id.present?
        end
      end
      
      # Update metric associations
      @report.report_metrics.destroy_all
      if params[:metric_ids].present?
        params[:metric_ids].each do |metric_id|
          @report.report_metrics.create(metric_id: metric_id) if metric_id.present?
        end
      end
      
      redirect_to @report, notice: 'Report updated successfully'
    else
      @alerts = current_user.alerts.not_deleted
      @metrics = current_user.metrics.not_deleted
      render :edit
    end
  end

  def soft_delete
    @report.soft_delete!
    redirect_to reports_path, notice: 'Report deleted successfully'
  end
  
  private
  
  def find_report
    @report = current_user.reports.not_deleted.find(params[:id])
  end
  
  def report_params
    params.require(:report).permit(:name, :time_of_day, :interval_type, :namespace, interval_config: {})
  end
end
