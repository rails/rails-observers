module ActionMailer
  class Railtie
    initializer "action_mailer.register_observers" do |app|

      ActiveSupport.on_load(:action_mailer) do
        register_observers(options.delete(:observers))
      end
    end
  end
end
