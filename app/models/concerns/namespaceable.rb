module Namespaceable
  extend ActiveSupport::Concern

  included do
    # Ensure namespace defaults to empty string
    before_save :normalize_namespace

    # Add scopes for namespace filtering
    scope :in_namespace, ->(namespace) { where(namespace: namespace || "") }
    scope :root_namespace, -> { where(namespace: "") }
  end

  class_methods do
    # Get all available namespaces for this model and user
    def namespaces_for_user(user)
      where(user: user)
        .where.not(namespace: "")
        .distinct
        .pluck(:namespace)
        .sort
    end

    # Get folder structure for namespace browsing
    def namespace_folders_for_user(user, current_namespace = "")
      namespaces = namespaces_for_user(user)

      # Filter namespaces that start with current_namespace
      prefix = current_namespace.present? ? "#{current_namespace}." : ""
      relevant_namespaces = namespaces.select { |ns| ns.start_with?(prefix) }

      # Get immediate child folders
      folders = Set.new
      relevant_namespaces.each do |namespace|
        # Remove the prefix to get relative path
        relative_path = namespace[prefix.length..-1]
        next if relative_path.blank?

        # Get the first component (immediate child folder)
        first_component = relative_path.split(".").first
        folders.add(first_component) if first_component.present?
      end

      folders.to_a.sort
    end

    # Get items directly in a specific namespace (not in subfolders)
    def items_in_namespace(user, namespace = "")
      in_namespace(namespace).where(user: user)
    end
  end

  # Get the parent namespace (one level up)
  def parent_namespace
    return "" if namespace.blank?

    parts = namespace.split(".")
    return "" if parts.length <= 1

    parts[0..-2].join(".")
  end

  # Get the immediate folder name (last component of namespace)
  def folder_name
    return "Root" if namespace.blank?
    namespace.split(".").last
  end

  # Get breadcrumb trail for current namespace
  def namespace_breadcrumbs
    return [ [ "Root", "" ] ] if namespace.blank?

    breadcrumbs = [ [ "Root", "" ] ]
    parts = namespace.split(".")

    parts.each_with_index do |part, index|
      namespace_path = parts[0..index].join(".")
      breadcrumbs << [ part, namespace_path ]
    end

    breadcrumbs
  end

  private

  def normalize_namespace
    self.namespace = "" if namespace.nil?
    self.namespace = namespace.strip
  end
end
