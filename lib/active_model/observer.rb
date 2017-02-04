require 'active_model'
module ActiveModel
  # == Active Model Observers
  #
  # Observer classes respond to life cycle callbacks to implement trigger-like
  # behavior outside the original class. This is a great way to reduce the
  # clutter that normally comes when the model class is burdened with
  # functionality that doesn't pertain to the core responsibility of the
  # class.
  #
  #   class CommentObserver < ActiveModel::Observer
  #     def after_save(comment)
  #       Notifications.comment('admin@do.com', 'New comment was posted', comment).deliver
  #     end
  #   end
  #
  # This Observer sends an email when a <tt>Comment#save</tt> is finished.
  #
  #   class ContactObserver < ActiveModel::Observer
  #     def after_create(contact)
  #       contact.logger.info('New contact added!')
  #     end
  #
  #     def after_destroy(contact)
  #       contact.logger.warn("Contact with an id of #{contact.id} was destroyed!")
  #     end
  #   end
  #
  # This Observer uses logger to log when specific callbacks are triggered.
  #
  # == Observing a class that can't be inferred
  #
  # Observers will by default be mapped to the class with which they share a
  # name. So <tt>CommentObserver</tt> will be tied to observing <tt>Comment</tt>,
  # <tt>ProductManagerObserver</tt> to <tt>ProductManager</tt>, and so on. If
  # you want to name your observer differently than the class you're interested
  # in observing, you can use the <tt>Observer.observe</tt> class method which
  # takes either the concrete class (<tt>Product</tt>) or a symbol for that
  # class (<tt>:product</tt>):
  #
  #   class AuditObserver < ActiveModel::Observer
  #     observe :account
  #
  #     def after_update(account)
  #       AuditTrail.new(account, 'UPDATED')
  #     end
  #   end
  #
  # If the audit observer needs to watch more than one kind of object, this can
  # be specified with multiple arguments:
  #
  #   class AuditObserver < ActiveModel::Observer
  #     observe :account, :balance
  #
  #     def after_update(record)
  #       AuditTrail.new(record, 'UPDATED')
  #     end
  #   end
  #
  # The <tt>AuditObserver</tt> will now act on both updates to <tt>Account</tt>
  # and <tt>Balance</tt> by treating them both as records.
  #
  # If you're using an Observer in a Rails application with Active Record, be
  # sure to read about the necessary configuration in the documentation for
  # ActiveRecord::Observer.
  class Observer
    include Singleton
    prepend Rails::Observers::Deprecation
    extend ActiveSupport::DescendantsTracker

    class << self
      # Attaches the observer to the supplied model classes.
      #
      #   class AuditObserver < ActiveModel::Observer
      #     observe :account, :balance
      #   end
      #
      #   AuditObserver.observed_classes # => [Account, Balance]
      def observe(*models)
        models.flatten!
        models.collect! { |model| model.respond_to?(:to_sym) ? model.to_s.camelize.constantize : model }
        singleton_class.redefine_method(:observed_classes) { models }
      end

      # Returns an array of Classes to observe.
      #
      #   AccountObserver.observed_classes # => [Account]
      #
      # You can override this instead of using the +observe+ helper.
      #
      #   class AuditObserver < ActiveModel::Observer
      #     def self.observed_classes
      #       [Account, Balance]
      #     end
      #   end
      def observed_classes
        unless defined?(@observed_classes)
          @observed_classes = Set.new
          @observed_classes << default_observed_class if default_observed_class
          @observed_classes.freeze
        end
        @observed_classes
      end

      # Returns the class observed by default. It's inferred from the observer's
      # class name.
      #
      #   PersonObserver.default_observed_class  # => Person
      #   AccountObserver.default_observed_class # => Account
      def default_observed_class
        return @default_observed_class if defined?(@default_observed_class)
        @default_observed_class = self.name.sub!(/Observer\z/, '').try(:safe_constantize)
      end
      deprecated_alias_method :observed_class, :default_observed_class
    end

    delegate :observed_classes, :to => :class

    # Start observing the declared classes and their subclasses.
    # Called automatically by the instance method.
    def initialize #:nodoc:
      observed_classes.each { |klass| add_observer!(klass) }
    end


    # Send observed_method(object) if the method exists and
    # the observer is enabled for the given object's class.
    def update(observed_method, object, *extra_args, &block) #:nodoc:
      return if !respond_to?(observed_method) || disabled_for?(object)
      send(observed_method, object, *extra_args, &block)
    end

    # Special method sent by the observed class when it is inherited.
    # Passes the new subclass.
    def observed_class_inherited(subclass) #:nodoc:
      self.class.observe(observed_classes + [subclass])
      add_observer!(subclass)
    end

  protected
    def add_observer!(klass) #:nodoc:
      klass.add_observer(self)
    end

    # Returns true if notifications are disabled for this object.
    def disabled_for?(object) #:nodoc:
      klass = object.class
      return false unless klass.respond_to?(:observers)
      klass.observers.disabled_for?(self)
    end
  end
end
