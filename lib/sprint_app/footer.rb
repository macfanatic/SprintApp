module SprintApp
  class Footer < ActiveAdmin::Component
    def build(*args)
      text_node render('shared/admin_footer')
    end
  end
end