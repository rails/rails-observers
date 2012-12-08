require 'rails/railtie'

module Rails
  module Observers
    class Railtie < ::Rails::Railtie
      initializer "active_record.observer", :before => "active_record.set_configs" do |app|
        ActiveSupport.on_load(:active_record) do
          require "rails/observers/activerecord/active_record"

          if observers = app.config.respond_to?(:active_record) && app.config.active_record.delete(:observers)
            send :observers=, observers
          end
        end
      end

      initializer "action_controller.caching.sweepers" do
        ActiveSupport.on_load(:action_controller) do
          require "rails/observers/action_controller/caching"
        end
      end

      config.after_initialize do |app|
        ActiveSupport.on_load(:active_record) do
          ActiveRecord::Base.instantiate_observers

          ActionDispatch::Reloader.to_prepare do
            ActiveRecord::Base.instantiate_observers
          end
        end
      end
    end
  end
end
