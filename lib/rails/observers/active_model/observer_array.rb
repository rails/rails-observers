require 'set'

module ActiveModel
  # Stores the enabled/disabled state of individual observers for
  # a particular model class.
  class ObserverArray < Array
    attr_reader :model_class
    def initialize(model_class, *args) #:nodoc:
      @model_class = model_class
      super(*args)
    end

    # Returns +true+ if the given observer is disabled for the model class,
    # +false+ otherwise.
    def disabled_for?(observer) #:nodoc:
      disabled_observers.include?(observer.class)
    end

    # Disables one or more observers. This supports multiple forms:
    #
    #   ORM.observers.disable :all
    #     # => disables all observers for all models subclassed from
    #     #    an ORM base class that includes ActiveModel::Observing
    #     #    e.g. ActiveRecord::Base
    #
    #   ORM.observers.disable :user_observer
    #     # => disables the UserObserver
    #
    #   User.observers.disable AuditTrail
    #     # => disables the AuditTrail observer for User notifications.
    #     #    Other models will still notify the AuditTrail observer.
    #
    #   ORM.observers.disable :observer_1, :observer_2
    #     # => disables Observer1 and Observer2 for all models.
    #
    #   User.observers.disable :all do
    #     # all user observers are disabled for
    #     # just the duration of the block
    #   end
    def disable(*observers, &block)
      set_enablement(false, observers, &block)
    end

    # Enables one or more observers. This supports multiple forms:
    #
    #   ORM.observers.enable :all
    #     # => enables all observers for all models subclassed from
    #     #    an ORM base class that includes ActiveModel::Observing
    #     #    e.g. ActiveRecord::Base
    #
    #   ORM.observers.enable :user_observer
    #     # => enables the UserObserver
    #
    #   User.observers.enable AuditTrail
    #     # => enables the AuditTrail observer for User notifications.
    #     #    Other models will not be affected (i.e. they will not
    #     #    trigger notifications to AuditTrail if previously disabled)
    #
    #   ORM.observers.enable :observer_1, :observer_2
    #     # => enables Observer1 and Observer2 for all models.
    #
    #   User.observers.enable :all do
    #     # all user observers are enabled for
    #     # just the duration of the block
    #   end
    #
    # Note: all observers are enabled by default. This method is only
    # useful when you have previously disabled one or more observers.
    def enable(*observers, &block)
      set_enablement(true, observers, &block)
    end

    protected

      def disabled_observers #:nodoc:
        DisabledObserversRegistry.disabled_observers_per_class[model_class] ||= Set.new
      end

      def disabled_observers= observers #:nodoc:
        DisabledObserversRegistry.disabled_observers_per_class[model_class] = observers
      end

      def observer_class_for(observer) #:nodoc:
        return observer if observer.is_a?(Class)

        if observer.respond_to?(:to_sym) # string/symbol
          observer.to_s.camelize.constantize
        else
          raise ArgumentError, "#{observer} was not a class or a " +
            "lowercase, underscored class name as expected."
        end
      end

      def start_transaction #:nodoc:
        disabled_observer_stack.push(disabled_observers.dup)
        each_subclass_array do |array|
          array.start_transaction
        end
      end

      def disabled_observer_stack #:nodoc:
        DisabledObserversRegistry.disabled_observers_stacks_per_class[model_class] ||= []
      end

      def end_transaction #:nodoc:
        self.disabled_observers = disabled_observer_stack.pop
        each_subclass_array do |array|
          array.end_transaction
        end
      end

      def transaction #:nodoc:
        start_transaction

        begin
          yield
        ensure
          end_transaction
        end
      end

      def each_subclass_array #:nodoc:
        model_class.descendants.each do |subclass|
          yield subclass.observers
        end
      end

      def set_enablement(enabled, observers) #:nodoc:
        if block_given?
          transaction do
            set_enablement(enabled, observers)
            yield
          end
        else
          observers = ActiveModel::Observer.descendants if observers == [:all]
          observers.each do |obs|
            klass = observer_class_for(obs)

            unless klass < ActiveModel::Observer
              raise ArgumentError.new("#{obs} does not refer to a valid observer")
            end

            if enabled
              disabled_observers.delete(klass)
            else
              disabled_observers << klass
            end
          end

          each_subclass_array do |array|
            array.set_enablement(enabled, observers)
          end
        end
      end
  end
end
