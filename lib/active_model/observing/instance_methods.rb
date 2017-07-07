module ActiveModel
  module Observing
    module InstanceMethods
      # Notify a change to the list of observers.
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
      #   Foo.instantiate_observers # => [FooObserver]
      #
      #   foo = Foo.new
      #   foo.status = false
      #   foo.notify_observers(:on_spec)
      #   foo.status # => true
      #
      # See ActiveModel::Observing::ClassMethods.notify_observers for more
      # information.
      def notify_observers(method, *extra_args)
        self.class.notify_observers(method, self, *extra_args)
      end
    end
  end
end
