module AdminHelper
  
  def restricted_actions_column(table)
    table.column "" do |resource|
      restricted_default_actions_for_resource(resource)
    end
  end

  def restricted_default_actions_for_resource(resource)
     actions = ""
     actions += link_to( "View", resource_path(resource), :class => "member_link" ) if can?( :view, resource )
     actions += link_to( "Edit", edit_resource_path(resource), :class => "member_link" ) if can?( :edit, resource )
     actions += link_to( "Delete", resource_path(resource), :method => :delete, :confirm => I18n.t('active_admin.delete_confirmation'), :class => "member_link") if can?( :destroy, resource )
     actions.html_safe
  end

  def modified_by(resource)
    user = AdminUser.find(resource.versions.last.whodunnit) rescue nil
    unless user.blank?
      link_to user.full_name, admin_user_url(user)
    else
      link_to "Unknown", "#"
    end
  end

  def modified_by_name(resource)
    AdminUser.find(resource.versions.last.whodunnit).full_name rescue "Unknown"
  end

  def created_by(resource)
    user = created_by_user(resource)
    unless user.nil?
      link_to user.full_name, admin_user_url(user)
    else
      link_to "Unknown", "#"
    end
  end

  def created_by_user(resource)
    AdminUser.find(resource.versions.where(event: :create).first.whodunnit) rescue nil
  end

  def created_by_name(resource)
    created_by_user(resource).full_name rescue "Unknown"
  end

  def better_format(object)
    case object
    when Date, Time
      localize(object, :format => :long)
    when String
      object
    else
      object.display_name rescue object.to_s
    end
  end

  def avatar(user)
    image_tag user.avatar_url, alt: user.full_name, class: :avatar if user.present?
  end

  def github_link(user)
    link_to "@#{user.github}", "https://github.com/#{user.github}", target: "_blank" unless user.github.blank?
  end
  
end