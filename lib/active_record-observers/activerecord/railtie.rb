module ActiveRecord
  class Railtie
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
