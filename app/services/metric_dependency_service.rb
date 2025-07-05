class MetricDependencyService
  def self.metrics_to_update(changed_metric_or_question)
    case changed_metric_or_question
    when Metric
      find_dependent_metrics(changed_metric_or_question)
    when Question
      find_metrics_using_question(changed_metric_or_question)
    else
      []
    end
  end

  def self.invalidate_caches_for(changed_entity)
    metrics_to_update = case changed_entity
    when Metric
      find_dependent_metrics(changed_entity)
    when Question
      find_metrics_using_question(changed_entity)
    when Answer, Response
      # For answers/responses, find metrics through their questions
      if changed_entity.is_a?(Answer)
        find_metrics_using_question(changed_entity.question)
      elsif changed_entity.is_a?(Response)
        changed_entity.answers.flat_map { |answer| find_metrics_using_question(answer.question) }.uniq
      else
        []
      end
    else
      []
    end

    # Clear metric series caches
    metrics_to_update.each do |metric|
      metric.metric_series_cache&.destroy
    end

    # Clear alert status caches for alerts using these metrics
    alert_ids = Alert.where(metric_id: metrics_to_update.map(&:id)).pluck(:id)
    AlertStatusCache.where(alert_id: alert_ids).destroy_all
  end

  private

  def self.find_dependent_metrics(metric)
    visited = Set.new
    to_visit = [metric]
    dependent_metrics = []

    while to_visit.any?
      current_metric = to_visit.pop
      next if visited.include?(current_metric.id)
      visited.add(current_metric.id)

      # Find metrics that use this metric as a child
      parent_metrics = Metric.joins(:child_metric_metrics)
                            .where(child_metric_metrics: { child_metric_id: current_metric.id })

      parent_metrics.each do |parent|
        dependent_metrics << parent
        to_visit << parent unless visited.include?(parent.id)
      end
    end

    dependent_metrics.uniq
  end

  def self.find_metrics_using_question(question)
    # Find metrics that directly reference this question
    direct_metrics = question.metrics

    # Find all metrics that depend on these direct metrics
    all_dependent = direct_metrics.flat_map { |metric| find_dependent_metrics(metric) }

    (direct_metrics + all_dependent).uniq
  end
end