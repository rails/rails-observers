module ActiveModel
  module Observing
    module ClassMethods
      prepend Rails::Observers::Deprecation
      def inherited(subclass)
        super
        subclass.observer_orm.instantiate_observers
        notify_observers :observed_class_inherited, subclass
      end
      
      # Activates the observers assigned.
      #
      #   class ORM
      #     include ActiveModel::Observing
      #   end
      #
      #   # Calls PersonObserver.instance
      #   ORM.observers = :person_observer
      #
      #   # Calls Cacher.instance and GarbageCollector.instance
      #   ORM.observers = :cacher, :garbage_collector
      #
      #   # Same as above, just using explicit class references
      #   ORM.observers = Cacher, GarbageCollector
      #
      # Note: Setting this does not instantiate the observers yet.
      # <tt>instantiate_observers</tt> is called during startup, and before
      # each development request.
      def observers=(*values)
        observers.replace(values.flatten)
      end

      # Gets an array of observers observing this model. The array also provides
      # +enable+ and +disable+ methods that allow you to selectively enable and
      # disable observers (see ActiveModel::ObserverArray.enable and
      # ActiveModel::ObserverArray.disable for more on this).
      #
      #   class ORM
      #     include ActiveModel::Observing
      #   end
      #
      #   ORM.observers = :cacher, :garbage_collector
      #   ORM.observers       # => [:cacher, :garbage_collector]
      #   ORM.observers.class # => ActiveModel::ObserverArray
      def observers
        @observers ||= ObserverArray.new(self)
      end

      # Returns the current observer instances.
      #
      #   class Foo
      #     include ActiveModel::Observing
      #
      #     attr_accessor :status
      #   end
      #
      #   class FooObserver < ActiveModel::Observer
      #     def on_spec(record, *args)
      #       record.status = true
      #     end
      #   end
      #
      #   Foo.observers = FooObserver
      #   Foo.instantiate_observers
      #
      #   Foo.observer_instances # => [#<FooObserver:0x007fc212c40820>]
      def observer_instances
        @observer_instances ||= Set.new
      end

      # Instantiate the global observers.
      #
      #   class Foo
      #     include ActiveModel::Observing
      #
      #     attr_accessor :status
      #   end
      #
      #   class FooObserver < ActiveModel::Observer
      #     def on_spec(record, *args)
      #       record.status = true
      #     end
      #   end
      #
      #   Foo.observers = FooObserver
      #
      #   foo = Foo.new
      #   foo.status = false
      #   foo.notify_observers(:on_spec)
      #   foo.status # => false
      #
      #   Foo.instantiate_observers # => [FooObserver]
      #
      #   foo = Foo.new
      #   foo.status = false
      #   foo.notify_observers(:on_spec)
      #   foo.status # => true
      def instantiate_observers
        observers.each { |o| instantiate_observer(o) }
      end

      # Add a new observer to the pool. The new observer needs to respond to
      # <tt>update</tt>, otherwise it raises an +ArgumentError+ exception.
      #
      #   class Foo
      #     include ActiveModel::Observing
      #   end
      #
      #   class FooObserver < ActiveModel::Observer
      #   end
      #
      #   Foo.add_observer(FooObserver.instance)
      #
      #   Foo.observers_instance
      #   # => [#<FooObserver:0x007fccf55d9390>]
      def add_observer(observer)
        unless observer.respond_to? :update
          raise ArgumentError, "observer needs to respond to 'update'"
        end
        observer_instances << observer
      end

      # Fires notifications to model's observers.
      #
      #   def save
      #     notify_observers(:before_save)
      #     ...
      #     notify_observers(:after_save)
      #   end
      #
      # Custom notifications can be sent in a similar fashion:
      #
      #   notify_observers(:custom_notification, :foo)
      #
      # This will call <tt>custom_notification</tt>, passing as arguments
      # the current object and <tt>:foo</tt>.
      def notify_observers(*args)
        observer_instances.each { |observer| observer.update(*args) }
      end

      # Returns the total number of instantiated observers.
      #
      #   class Foo
      #     include ActiveModel::Observing
      #
      #     attr_accessor :status
      #   end
      #
      #   class FooObserver < ActiveModel::Observer
      #     def on_spec(record, *args)
      #       record.status = true
      #     end
      #   end
      #
      #   Foo.observers = FooObserver
      #   Foo.observers_count # => 0
      #   Foo.instantiate_observers
      #   Foo.observers_count # => 1
      def observers_count
        observer_instances.size
      end
      deprecated_alias_method :count_observers, :observers_count

    protected
      def instantiate_observer(observer) #:nodoc:
        # string/symbol
        if observer.respond_to?(:to_sym)
          observer = observer.to_s.camelize.constantize
        end
        if observer.respond_to?(:instance)
          observer.instance
        else
          raise ArgumentError,
            "#{observer} must be a lowercase, underscored class name (or " +
            "the class itself) responding to the method :instance. " +
            "Example: Person.observers = :big_brother # calls " +
            "BigBrother.instance"
        end
      end
    end
  end
end
