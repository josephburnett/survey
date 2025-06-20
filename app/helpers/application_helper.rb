module ApplicationHelper
  def all_namespaces_for_user(user)
    namespaces = Set.new
    
    # Collect namespaces from all namespaceable models
    [Form, Section, Question, Answer, Response, Metric, Dashboard].each do |model|
      namespaces.merge(model.namespaces_for_user(user))
    end
    
    namespaces.to_a.sort
  end
end
