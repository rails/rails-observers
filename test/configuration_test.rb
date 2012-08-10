class ::MyMailObserver
  def self.delivered_email(email); email; end
end

class ::MyOtherMailObserver < ::MyMailObserver; end

module ApplicationTests
  class ConfigurationTest < ActiveSupport::TestCase
    include ActiveSupport::Testing::Isolation

    test "registers observers with ActionMailer" do
      add_to_config <<-RUBY
        config.action_mailer.observers = MyMailObserver
      RUBY

      require "#{app_path}/config/environment"
      require "mail"

      _ = ActionMailer::Base

      assert_equal [::MyMailObserver], ::Mail.send(:class_variable_get, "@@delivery_notification_observers")
    end

    test "registers multiple observers with ActionMailer" do
      add_to_config <<-RUBY
        config.action_mailer.observers = [MyMailObserver, "MyOtherMailObserver"]
      RUBY

      require "#{app_path}/config/environment"
      require "mail"

      _ = ActionMailer::Base

      assert_equal [::MyMailObserver, ::MyOtherMailObserver], ::Mail.send(:class_variable_get, "@@delivery_notification_observers")
    end

    test "config.active_record.observers" do
      add_to_config <<-RUBY
        config.active_record.observers = :foo_observer
      RUBY

      app_file 'app/models/foo.rb', <<-RUBY
        class Foo < ActiveRecord::Base
        end
      RUBY

      app_file 'app/models/foo_observer.rb', <<-RUBY
        class FooObserver < ActiveRecord::Observer
        end
      RUBY

      require "#{app_path}/config/environment"

      ActiveRecord::Base
      assert defined?(FooObserver)
    end
  end
end
