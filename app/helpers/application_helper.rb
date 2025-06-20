module ApplicationHelper
  def all_namespaces_for_user(user)
    namespaces = Set.new
    
    # Collect all possible namespaces from all namespaceable models
    [Form, Section, Question, Answer, Response, Metric, Dashboard].each do |model|
      namespaces.merge(model.namespaces_for_user(user))
    end
    
    # Filter out namespaces that don't actually have any entities
    active_namespaces = namespaces.select do |namespace|
      [Form, Section, Question, Answer, Response, Metric, Dashboard].any? do |model|
        model.where(user: user, namespace: namespace).exists?
      end
    end
    
    active_namespaces.sort
  end
end
