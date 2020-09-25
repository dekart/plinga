module Plinga
  class Engine < ::Rails::Engine
    initializer "plinga.middleware" do |app|
      app.middleware.insert_before(Rack::Head, Plinga::Middleware)
    end

    initializer "plinga.controller_extension" do
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send(:include, Plinga::Rails::Controller)
      end
    end
  end
end
