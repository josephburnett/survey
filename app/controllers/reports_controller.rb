class ReportsController < ApplicationController
  include NamespaceBrowsing
  require "timeout"

  before_action :require_login
  before_action :find_report, only: [ :edit, :update, :soft_delete ]

  def index
    setup_namespace_browsing(Report, :reports_path)
    @items = Report.items_in_namespace(current_user, @current_namespace).not_deleted
  end

  def show
    # Preload associations to avoid N+1 queries
    @report = current_user.reports.not_deleted
                          .includes(alerts: :metric, metrics: [])
                          .find(params[:id])

    # Pre-calculate expensive metric summaries to avoid timeouts
    @metric_summaries = @report.metrics.map do |metric|
      begin
        # Set a timeout for expensive series calculation
        series_data = Timeout.timeout(5) { metric.series }
        latest_value = series_data&.last&.last
        data_count = series_data&.count || 0

        {
          metric: metric,
          latest_value: latest_value,
          data_count: data_count,
          has_data: data_count > 0
        }
      rescue Timeout::Error, StandardError => e
        Rails.logger.warn "Metric #{metric.id} series calculation failed: #{e.message}"
        {
          metric: metric,
          latest_value: nil,
          data_count: 0,
          has_data: false,
          error: true
        }
      end
    end

    # Pre-calculate alert summaries
    @alert_summaries = @report.alerts.map do |alert|
      begin
        # Use existing activated? method which may be more efficient
        is_activated = alert.activated?

        # Only get latest value if we need it, with timeout
        latest_value = nil
        if alert.metric
          series_data = Timeout.timeout(3) { alert.metric.series }
          latest_value = series_data&.last&.last
        end

        {
          alert: alert,
          is_activated: is_activated,
          latest_value: latest_value
        }
      rescue Timeout::Error, StandardError => e
        Rails.logger.warn "Alert #{alert.id} calculation failed: #{e.message}"
        {
          alert: alert,
          is_activated: false,
          latest_value: nil,
          error: true
        }
      end
    end

    # Pre-calculate report status to avoid repeated expensive calls
    @report_status = {
      has_content: safe_has_content_to_send?,
      should_send: safe_should_send_now?,
      active_alerts_count: @alert_summaries.count { |s| s[:is_activated] }
    }
  end

  def new
    @report = Report.new
    @alerts = current_user.alerts.not_deleted
    @metrics = current_user.metrics.not_deleted
  end

  def create
    @report = current_user.reports.build(report_params)

    # Handle interval_config processing
    if params[:interval_config].present?
      case params[:report][:interval_type]
      when "weekly"
        if params[:interval_config][:days].present?
          @report.interval_config = { "days" => params[:interval_config][:days].reject(&:blank?) }
        else
          @report.interval_config = { "days" => [] }
        end
      when "monthly"
        if params[:interval_config][:day_of_month].present?
          @report.interval_config = { "day_of_month" => params[:interval_config][:day_of_month].to_i }
        else
          @report.interval_config = {}
        end
      end
    else
      @report.interval_config = {}
    end

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

      redirect_to @report, notice: "Report created successfully"
    else
      @alerts = current_user.alerts.not_deleted
      @metrics = current_user.metrics.not_deleted
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @alerts = current_user.alerts.not_deleted
    @metrics = current_user.metrics.not_deleted
  end

  def update
    # Handle interval_config processing
    if params[:interval_config].present?
      case params[:report][:interval_type]
      when "weekly"
        if params[:interval_config][:days].present?
          @report.interval_config = { "days" => params[:interval_config][:days].reject(&:blank?) }
        else
          @report.interval_config = { "days" => [] }
        end
      when "monthly"
        if params[:interval_config][:day_of_month].present?
          @report.interval_config = { "day_of_month" => params[:interval_config][:day_of_month].to_i }
        else
          @report.interval_config = {}
        end
      end
    else
      @report.interval_config = {}
    end

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

      redirect_to @report, notice: "Report updated successfully"
    else
      @alerts = current_user.alerts.not_deleted
      @metrics = current_user.metrics.not_deleted
      render :edit, status: :unprocessable_entity
    end
  end

  def soft_delete
    @report.soft_delete!
    redirect_to reports_path, notice: "Report deleted successfully"
  end

  private

  def find_report
    @report = current_user.reports.not_deleted.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:name, :time_of_day, :interval_type, :namespace, interval_config: {})
  end

  def safe_has_content_to_send?
    # Check metrics first (fast operation)
    return true if @report.metrics.any?

    # Only check active alerts if no metrics (potentially slow operation)
    begin
      Timeout.timeout(3) { @report.active_alerts.any? }
    rescue Timeout::Error, StandardError => e
      Rails.logger.warn "Report #{@report.id} active_alerts check failed: #{e.message}"
      false
    end
  end

  def safe_should_send_now?
    Timeout.timeout(3) { @report.should_send_now? }
  rescue Timeout::Error, StandardError => e
    Rails.logger.warn "Report #{@report.id} should_send_now failed: #{e.message}"
    false
  end
end
