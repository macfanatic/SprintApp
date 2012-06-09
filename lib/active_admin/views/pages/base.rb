module ActiveAdmin
  module Views
    module Pages
      class Base
        
        def build_page_content
          add_favicon
          javascript_tag("var AUTH_TOKEN = #{form_authenticity_token.inspect};") if protect_against_forgery?
          build_sub_menu
          build_flash_messages
          div :id => "active_admin_content", :class => (skip_sidebar? ? "without_sidebar" : "with_sidebar") do
            build_main_content_wrapper
            build_sidebar unless skip_sidebar?
            div class: "cleared"
          end
        end
        
        def add_favicon
          within @head do
            text_node favicon_link_tag
            
            meta name: "apple-mobile-web-app-capable", content: "yes"
            meta name: "apple-mobile-web-app-status-bar-style", content: "black"
            meta name: "viewport", content: "width=device-width, initial-scale=1"
            
            link rel: "apple-touch-icon", sizes: "57x57", href: path_to_image("touch-icon-57.png")
            link rel: "apple-touch-icon", sizes: "72x72", href: path_to_image("touch-icon-72.png")
            link rel: "apple-touch-icon", sizes: "114x114", href: path_to_image("touch-icon-114.png")
            link rel: "apple-touch-icon", sizes: "144x144", href: path_to_image("touch-icon-144.png")
            
            link rel: "apple-touch-startup-image", media: "screen and (min-device-width: 481px) and (max-device-width: 1024px) and (orientation:landscape)", href: path_to_image("ipad-splash-landscape.png")
            link rel: "apple-touch-startup-image", media: "screen and (min-device-width: 481px) and (max-device-width: 1024px) and (orientation:portrait)", href: path_to_image("ipad-splash-portrait.png")
            link rel: "apple-touch-startup-image", media: "screen and (max-device-width: 320px)", href: path_to_image("iphone-splash-portrait.png")
          end
        end
        
        def build_page
          within @body do
            div :id => "wrapper" do
              build_timer_bar
              build_header
              build_title_bar
              build_page_content
              build_footer
            end
            build_extra_content
          end
        end
        
        def build_timer_bar
          text_node render 'shared/ipad_warning'
          text_node render "shared/timer"
        end
        
        def build_sub_menu
          
          unless active_admin_config.nil?
            
            res = active_admin_config.resource_name.underscore
            if %w(project milestone ticket project_file).include? res 
              
              return if res == "project" and ( current_page?(:action => :new) or current_page?(:action => :index) )
              return if res == "ticket" and params[:project_id].blank?
              
              if @resource.nil?
                project_id = params.include?( :project_id ) ? params[:project_id] : params[:id]
                current_project = Project.find_by_url!(project_id) rescue return 
              else
                current_project = res == "project" ? @resource : @resource.project
              end
              
              div :id => "detail_nav" do
              
                ul :id => "tabs" do
                                    
                  opts = ( res == "project" and current_page?( :action => :roadmap ) ) ? { :class => "current" } : {}
                  li opts do
                    link_to "Roadmap", roadmap_project_path( current_project )
                  end
        
                  opts = res == "ticket" ?  { :class => "current" } : nil
                  li opts do
                    link_to "Tickets", project_tickets_path( current_project )
                  end
                                  
                  opts = res == "milestone" ?  { :class => "current" } : nil
                  li opts do
                    link_to "Milestones", project_milestones_path( current_project )
                  end
                  
                  opts = ( res == "project" and current_page?( :action => :show ) ) ? { :class => "current" } : nil
                  li opts do
                    link_to "Overview", project_path( current_project )
                  end   
                  
                  opts = ( res == "project" and current_page?( :action => :whiteboard ) ) ? { :class => "current" } : nil
                  li opts do
                    link_to "Whiteboard", whiteboard_project_path( current_project )
                  end  
                  
                  opts = res == "project_file"  ? { :class => "current" } : nil
                  li opts do
                    link_to "Documents", project_project_files_path( current_project )
                  end           
                
                end
              end
            end
            
          end
          
        end
        
      end   
    end
  end
end