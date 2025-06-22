module NamespaceBrowsing
  extend ActiveSupport::Concern
  
  def setup_namespace_browsing(model_class, path_helper)
    @current_namespace = params[:namespace] || ''
    # Use ALL namespaces, not just those specific to this entity type
    @folders = Namespace.namespace_folders_for_user(current_user, @current_namespace)
    @breadcrumbs = build_namespace_breadcrumbs(@current_namespace, path_helper)
  end
  
  private
  
  def build_namespace_breadcrumbs(current_namespace, path_helper)
    return [['Root', send(path_helper)]] if current_namespace.blank?
    
    breadcrumbs = [['Root', send(path_helper)]]
    parts = current_namespace.split('.')
    
    parts.each_with_index do |part, index|
      namespace_path = parts[0..index].join('.')
      breadcrumbs << [part, send(path_helper, namespace: namespace_path)]
    end
    
    breadcrumbs
  end
end