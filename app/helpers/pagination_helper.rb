module PaginationHelper

  # Gives me the basic :index renderer, without scopes or the filter sidebar
  def flexible_paginated_collection(collection, opts = {}, &block)
    div :class => "paginated_collection" do
    
      opts[:sortable] = true unless opts.include?( :sortable )
    
      unless opts[:skip_info]
      
      	div :class => "pagination_information" do

      		entry_name = opts[:entry_name]

      		 if collection.num_pages < 2
      	      case collection.size
      	      when 0; I18n.t('active_admin.pagination.empty', :model => entry_name.pluralize).html_safe
      	      when 1; I18n.t('active_admin.pagination.one', :model => entry_name).html_safe
      	      else;   I18n.t('active_admin.pagination.one_page', :model => entry_name.pluralize, :n => collection.size).html_safe
      	      end
      	    else
      	      offset = collection.current_page * active_admin_application.default_per_page
      	      total  = collection.total_count
      	      I18n.t('active_admin.pagination.multiple', :model => entry_name.pluralize, :from => (offset - active_admin_application.default_per_page + 1), :to => offset > total ? total : offset, :total => total).html_safe
      	    end

      	end
    	
    	end

    	div :class => "paginated_collection_contents" do
    		div :class => 'index_content' do
    			table_for( collection, { :class => "index_table", :sortable => opts[:sortable] }, &block)
    		end
    	end
    
      unless opts[:skip_pagination]
      	div :id => "index_footer" do
      		paginate collection
      	end
    	end

    end
  end
  
end