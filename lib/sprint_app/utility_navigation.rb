module SprintApp

  class UtilityNavigation < ActiveAdmin::Component
    def build(namespace)
      text_node render('shared/utility_navigation')
    end  
  end
  
end