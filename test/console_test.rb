require 'isolation/abstract_unit'
require 'rails-observers'

class ConsoleTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  def setup
    build_app
    boot_rails
  end

  def teardown
    teardown_app
  end

  def load_environment
    require "#{rails_root}/config/environment"
    Rails.application.sandbox = false
    Rails.application.load_console
  end

  def test_active_record_does_not_panic_when_referencing_an_observed_constant
    add_to_config "config.active_record.observers = :user_observer"

    app_file "app/models/user.rb", <<-MODEL
      class User < ActiveRecord::Base
      end
    MODEL

    app_file "app/models/user_observer.rb", <<-MODEL
      class UserObserver < ActiveRecord::Observer
      end
    MODEL

    load_environment
    assert_nothing_raised { User }
  end
end
