require 'active_support/deprecation'
require 'active_support/backtrace_cleaner'
module Rails
  module Observers
    module Deprecation
      class << self
        def prepend_features(klass)
          class << klass
            prepend ::Rails::Observers::Deprecation::Methods
            singleton_class.prepend ::Rails::Observers::Deprecation::Methods
          end
          #klass.prepend ::Rails::Observers::Deprecation::Methods
          #TODO: Add backtrace cleaner
        end

        def warn(message, callstack = nil)
          callstack ||= caller_locations(3)
          ::ActiveSupport::Deprecation.warn(message, callstack)
        end
      end

      mattr_accessor :deprecator do
        ActiveSupport::Deprecation.new 'in the future', 'rails-observers'
      end

      module Methods
      private
        def deprecate_methods(*args)
          deprecator.deprecate_methods(self, *args)
        end

        def deprecated_alias_method(target, source)
          self.send :alias_method, target, source
          deprecator.deprecate_methods(self, target => source)
        end
        def deprecated_object_proxy(*args)
          ActiveSupport::Deprecation::DeprecatedObjectProxy.new(*args, deprecator)
        end

        def deprecated_instance_variable_proxy(*args)
          ActiveSupport::Deprecation::DeprecatedInstanceVariableProxy.new(*args, deprecator)
        end
        
        def deprecated_constant_proxy(*args)
          ActiveSupport::Deprecation::DeprecatedConstantProxy.new(*args, deprecator)
        end

        def deprecation_warn(message, callstack = nil)
          callstack ||= caller_locations(3)
          ::ActiveSupport::Deprecation.warn(message, callstack)
        end

        delegate :behavior, :behavior=, :to => :deprecator, :prefix => :deprecation
        delegate :silence, :silenced, :silenced=, :debug, :debug=, :to => :deprecator, :prefix => :deprecation

        def deprecator
          ::Rails::Observers::Deprecation.deprecator
        end
      end
    end
  end
end
