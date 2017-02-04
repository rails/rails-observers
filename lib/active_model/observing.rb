require 'active_model'
module ActiveModel
  # == Active Model Observers Activation
  module Observing
    extend ActiveSupport::Autoload
    autoload :ClassMethods
    autoload :InstanceMethods
    class << self
      def prepend_features(klass)
        class << klass
          include ::ActiveSupport::DescendantsTracker
          prepend ::ActiveModel::Observing::ClassMethods
        end
        klass.mattr_reader :observer_orm { klass }
        klass.prepend ::ActiveModel::Observing::InstanceMethods
        add_instantiation_hooks!(klass)
      end
      # Previously, people called include ActiveModel::Observing
      # so let's be backwards compatible
      alias_method :append_features, :prepend_features

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
