require 'minitest/autorun'

require 'fileutils'

require 'rails/all'
require 'rails/generators'
require 'rails/generators/test_case'

module Rails
  def self.root
    @root ||= File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures'))
  end
end

module TestApp
  class Application < Rails::Application
  end
end

# Call configure to load the settings from
# Rails.application.config.generators to Rails::Generators
Rails.application.load_generators

module GeneratorsTestHelper
  def self.included(base)
    base.class_eval do
      destination File.join(Rails.root, "tmp")
      setup :prepare_destination

      def teardown
        FileUtils.rm_rf(File.join(Rails.root, "tmp"))
      end

      begin
        base.tests Rails::Generators.const_get(base.name.sub(/Test$/, ''))
      rescue
      end
    end
  end
end

require 'rails/generators/rails/observer/observer_generator'

class NamespacedObserverGeneratorTest < Rails::Generators::TestCase
  include GeneratorsTestHelper

  def setup
    super
    Rails::Generators.namespace = TestApp
  end

  arguments %w(account)
  tests Rails::Generators::ObserverGenerator

  def test_invokes_default_orm
    run_generator
    assert_file "app/models/test_app/account_observer.rb", /module TestApp/, /  class AccountObserver < ActiveRecord::Observer/
  end

  def test_invokes_default_orm_with_class_path
    run_generator ["admin/account"]
    assert_file "app/models/test_app/admin/account_observer.rb", /module TestApp/, /  class Admin::AccountObserver < ActiveRecord::Observer/
  end

  def test_invokes_default_test_framework
    run_generator
    assert_file "test/unit/test_app/account_observer_test.rb", /module TestApp/, /  class AccountObserverTest < ActiveSupport::TestCase/
  end
end
