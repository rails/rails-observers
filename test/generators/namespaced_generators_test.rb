require 'generators/generators_test_helper'
require 'generators/rails/observer/observer_generator'

class NamespacedObserverGeneratorTest < Rails::Generators::TestCase
  tests Rails::Generators::ObserverGenerator
  arguments %w(account)
  destination File.expand_path("../../tmp", __FILE__)

  def setup
    super
    prepare_destination
    Rails::Generators.namespace = TestApp
  end

  def teardown
    super
    Rails::Generators.namespace = nil
  end

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
