module ActionMailer
  # Action Mailer provides hooks into the Mail observer and interceptor methods. These allow you to
  # register classes that are called during the mail delivery life cycle.
  #
  # An observer class must implement the <tt>:delivered_email(message)</tt> method which will be
  # called once for every email sent after the email has been sent.
  #
  class Base
    class << self
      # Register one or more Observers which will be notified when mail is delivered.
      def register_observers(*observers)
        observers.flatten.compact.each { |observer| register_observer(observer) }
      end

      # Register an Observer which will be notified when mail is delivered.
      # Either a class or a string can be passed in as the Observer. If a string is passed in
      # it will be <tt>constantize</tt>d.
      def register_observer(observer)
        delivery_observer = (observer.is_a?(String) ? observer.constantize : observer)
        Mail.register_observer(delivery_observer)
      end
    end
  end
end
