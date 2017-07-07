require 'generators/generators_test_helper'
require 'generators/observer_generator'

class ObserverGeneratorTest < Rails::Generators::TestCase
  tests Rails::Generators::ObserverGenerator
  destination File.expand_path("../../tmp", __FILE__)
  arguments %w(account)

  def setup
    super
    prepare_destination
  end

  def test_invokes_default_orm
    run_generator
    assert_file "app/models/account_observer.rb", /class AccountObserver < ActiveRecord::Observer/
  end

  def test_invokes_default_orm_with_class_path
    run_generator ["admin/account"]
    assert_file "app/models/admin/account_observer.rb", /class Admin::AccountObserver < ActiveRecord::Observer/
  end

  def test_invokes_default_test_framework
    run_generator
    assert_file "test/unit/account_observer_test.rb", /class AccountObserverTest < ActiveSupport::TestCase/
  end

  def test_logs_if_the_test_framework_cannot_be_found
    content = run_generator ["account", "--test-framework=rspec"]
    assert_match(/rspec \[not found\]/, content)
  end
end
