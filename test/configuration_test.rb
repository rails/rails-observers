require 'isolation/abstract_unit'
require 'rails-observers'

class ConfigurationTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  def setup
    build_app
    boot_rails
    FileUtils.rm_rf("#{app_path}/config/environments")
  end

  def teardown
    teardown_app
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

    _ = ActiveRecord::Base
    assert defined?(FooObserver)
  end
end
