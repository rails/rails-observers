require 'active_model'
module ActiveModel
  # == Active Model Observers Activation
  module Observing
    extend ActiveSupport::Autoload
    autoload :ClassMethods
    autoload :InstanceMethods
    autoload :DeferredModelLoader

    class << self

      def prepend_features(klass)
        klass.mattr_reader(:observer_orm) { self }
        class << klass
          include ::ActiveSupport::DescendantsTracker
          prepend ::ActiveModel::Observing::ClassMethods
        end

        klass.prepend ::ActiveModel::Observing::InstanceMethods
        add_instantiation_hooks!(klass)
      end

    private

      def add_instantiation_hooks!(klass)
        @@reloader_class = begin
          ::ActiveSupport::Reloader
        rescue NameError
          ::ActionDispatch::Reloader
        end
        ActiveSupport.on_load :after_initialize, :yield => true do
          klass.instantiate_observers
          @@reloader_class.to_prepare(klass) do |base|
            base.instantiate_observers
          end
        end
      end

    end
  end
end
