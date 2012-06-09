module SprintHelper

  def colorize_hours_per_team_member_for_sprint(hours)
    if hours >= 35
      :red
    elsif hours >= 30
      :orange
    elsif hours >= 20
      :green
    else
      :blue
    end
  end

  def scope_buttons(*scopes, &block)
    options = scopes.extract_options!
    div class: "table_tools" do
      ul class: "scopes table_tools_segmented_control" do
        scopes.each do |scope|
          classes = ["scope"]
          classes << "selected" if current_scope?(scope)
          li class: classes.join(" ") do
             a :href => url_for(params.merge(:scope => scope.id, :page => 1)), :class => "table_tools_button" do
               text_node scope.name
               span(:class => 'count') { "(" + get_scope_count(scope).to_s + ")" } if options[:scope_count]
             end
          end
        end
      end
    end
  end
  
end