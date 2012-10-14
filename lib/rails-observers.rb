require "rails/observers/version"

module Rails
  module Observes
    module Railtie < Rails::Railtie
      initializer "active_record.observer" do
        ActiveSupport.on_load(:active_record) do
          require "rails/observers/activerecord/active_record"
        end
      end

      initializer "action_controller.caching.sweppers" do
        ActiveSupport.on_load(:action_controller) do
          require "rails/observers/action_controller/caching"
        end
      end

      config.after_initialize do |app|
        ActiveSupport.on_load(:active_record) do
          ActiveRecord::Model.instantiate_observers

          ActionDispatch::Reloader.to_prepare do
            ActiveRecord::Model.instantiate_observers
          end
        end
      end
    end
  end
end
