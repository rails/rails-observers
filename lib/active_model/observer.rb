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
  # takes either a string or a symbol containing the name of that class
  # (<tt>:product</tt>):
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
    include Rails::Observers::Deprecation
    extend ActiveSupport::DescendantsTracker

    class << self
      # Attaches the observer to the supplied model class names.
      #
      #   class AuditObserver < ActiveModel::Observer
      #     observe 'Account', 'Balance'
      #   end
      def observe(*models)
        instance.observees = models
      end
    end

    # Start observing the declared classes and their subclasses.
    # Called automatically by the instance method.
    def initialize
      @observees = ObserveeSet.new(self)
      @default_observee = self.class.name.sub!(/Observer\z/, '').freeze
      observees << default_observee if default_observee?
    end

    # Returns an array of names of classes to observe.
    #
    #   AccountObserver.observees # => [:account]
    #
    # By default, the observed class name is obtained by removing 'Observer' from
    # from the end of the observer's name. If the observer's class name doesn't end
    # in 'Observer', no class is observed by default.


    # Attaches the observer to the supplied model class names.
    #
    #   AuditObserver.observees = [ 'Account', 'Balance' ]
    attr_reader :observees
    def observees=(models)
      observees.replace(models)
    end

    # Attaches the observer to a new model class *without* removing the previous ones.
    def observe!(klass)
      observees << klass.is_a?(String) ? klass : klass.name
    end

    # Returns an array of observed models (as strings), both those that are being observed,
    # and those that will be once they are loaded
    #
    #   AuditObserver.observed_classes # => [ 'Account', 'Balance' ]
    def observed_classes
      observees.all.map(&:model_name).freeze
    end

    # Returns an array of observed models (as strings) that are loaded.
    #
    #   AuditObserver.loaded_observed_classes # => [ 'Account', 'Balance' ]
    def loaded_observed_classes
      observees.loaded.map(&:model_name).freeze
    end

    # Returns an array of as-of-yet unloaded models (as strings) that will be observed.
    #
    #   AuditObserver.pending_observed_classes # => [ 'Account', 'Balance' ]
    def pending_observed_classes
      observees.pending.map(&:model_name).freeze
    end


    # Returns the class (if any) observed by default. It's inferred from the observer's
    # class name and obtained by simply removing the word 'Observer' from the end (if present).
    #
    #   PersonObserver.default_observee  # => Person
    #   AccountObserver.default_observee # => Account
    attr_reader :default_observee
    attr_predicate :default_observee

    # TODO: Add a method_added callback to watch that no one redefines observed_class(es) and
    # raise fire a deprecation error if so.

    # Send observed_method(object) if the method exists and
    # the observer is enabled for the given object's class.
    def update(observed_method, object, *extra_args, &block) #:nodoc:
      return if !respond_to?(observed_method) || disabled_for?(object)
      send(observed_method, object, *extra_args, &block)
    end

    # Special method sent by the observed class when it is inherited.
    # Passes the new subclass.
    def observed_class_inherited(subclass) #:nodoc:
      observed_classes << subclass
      observer!(subclass)
    end

  protected
    # Returns true if notifications are disabled for this object.
    def disabled_for?(object)
      klass = object.class
      return false unless klass.respond_to?(:observers)
      klass.observers.disabled_for?(self)
    end
  end
end
