module ApplicationHelper
  def all_namespaces_for_user(user)
    namespaces = Set.new
    
    # Collect all possible namespaces from all namespaceable models
    [Form, Section, Question, Answer, Response, Metric, Alert, Dashboard].each do |model|
      namespaces.merge(model.namespaces_for_user(user))
    end
    
    # Filter out namespaces that don't actually have any entities
    active_namespaces = namespaces.select do |namespace|
      [Form, Section, Question, Answer, Response, Metric, Alert, Dashboard].any? do |model|
        model.where(user: user, namespace: namespace).exists?
      end
    end
    
    active_namespaces.sort
  end
  
  def current_namespace
    # Try to get namespace from various sources in order of preference
    if instance_variable_defined?('@current_namespace')
      @current_namespace
    elsif instance_variable_defined?('@form') && @form
      @form.namespace
    elsif instance_variable_defined?('@section') && @section
      @section.namespace
    elsif instance_variable_defined?('@question') && @question
      @question.namespace
    elsif instance_variable_defined?('@answer') && @answer
      @answer.namespace
    elsif instance_variable_defined?('@response') && @response
      @response.namespace
    elsif instance_variable_defined?('@metric') && @metric
      @metric.namespace
    elsif instance_variable_defined?('@alert') && @alert
      @alert.namespace
    elsif instance_variable_defined?('@dashboard') && @dashboard
      @dashboard.namespace
    elsif instance_variable_defined?('@namespace') && @namespace
      @namespace.name
    elsif params[:namespace]
      params[:namespace]
    else
      ''
    end
  end
  
  def namespace_aware_path(model_class, path_method)
    namespace = current_namespace || ''
    
    # Check if the target model has items in the current namespace
    if namespace.present? && current_user && model_class.where(user: current_user, namespace: namespace).exists?
      send(path_method, namespace: namespace)
    else
      # Fall back to root namespace
      send(path_method)
    end
  end
end
