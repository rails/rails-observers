require 'generators/generators_test_helper'
require 'rails/generators/rails/observer/observer_generator'

class NamespacedObserverGeneratorTest < Rails::Generators::TestCase
  include GeneratorsTestHelper

  def setup
    super
    Rails::Generators.namespace = TestApp
  end

  def teardown
    super
    Rails::Generators.namespace = nil
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
