module SprintApp::ResourceExtensions

  private

  def add_default_action_items
    add_action_item :except => [:new, :show] do
      if controller.current_ability.can?(:create, active_admin_config.resource_name.underscore.camelize.constantize)
        if controller.action_methods.include?('new')
          link_to(I18n.t('active_admin.new_model', :model => active_admin_config.resource_name), new_resource_path)
        end
      end
    end

    # Edit link on show
    add_action_item :only => :show do
     if controller.current_ability.can?(:update, resource)
        if controller.action_methods.include?('edit')
          link_to(I18n.t('active_admin.edit_model', :model => active_admin_config.resource_name), edit_resource_path(resource))
        end
      end
    end

    # Destroy link on show
    add_action_item :only => :show do
      if controller.current_ability.can?(:destroy, resource)
        if controller.action_methods.include?("destroy")
          link_to(I18n.t('active_admin.delete_model', :model => active_admin_config.resource_name),
            resource_path(resource),
            :method => :delete, :confirm => I18n.t('active_admin.delete_confirmation'))
        end
      end
    end
  end
end
