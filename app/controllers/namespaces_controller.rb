class NamespacesController < ApplicationController
  before_action :require_login
  before_action :find_namespace, only: [ :show ]

  def index
    # Redirect to root namespace view
    redirect_to namespace_path("root")
  end

  def show
    if request.post?
      # Handle bulk move
      Rails.logger.info "Bulk move params: #{params.inspect}"
      target_namespace = params[:target_namespace] || ""
      entity_params = params[:entities] || {}

      Rails.logger.info "Target namespace: #{target_namespace.inspect}"
      Rails.logger.info "Entity params: #{entity_params.inspect}"

      moved_count = 0

      # Process each entity type
      entity_params.each do |entity_type, entity_ids|
        next if entity_ids.blank?

        Rails.logger.info "Processing #{entity_type}: #{entity_ids.inspect}"
        model_class = entity_type.singularize.camelize.constantize
        entities = model_class.where(id: entity_ids, user: current_user)

        Rails.logger.info "Found #{entities.count} entities to update"
        result = entities.update_all(namespace: target_namespace)
        Rails.logger.info "Update result: #{result}"
        moved_count += entities.count
      end

      Rails.logger.info "Total moved count: #{moved_count}"

      if moved_count > 0
        target_display = target_namespace.present? ? target_namespace : "Root"
        redirect_to namespace_path(@namespace), notice: "Successfully moved #{moved_count} #{'item'.pluralize(moved_count)} to #{target_display}"
      else
        redirect_to namespace_path(@namespace), alert: "No items were selected for moving"
      end
    else
      # GET request - show the namespace with child namespaces and bulk move form
    end
  end

  private

  def find_namespace
    namespace_name = params[:id] == "root" ? "" : params[:id]
    @namespace = Namespace.find_for_user(current_user, namespace_name)
  rescue ActiveRecord::RecordNotFound
    redirect_to namespace_path("root"), alert: "Namespace not found"
  end
end
