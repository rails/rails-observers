require 'helper'
require 'action_controller'
require 'rails/observers/activerecord/active_record'
require 'rails/observers/action_controller/caching'

SharedTestRoutes = ActionDispatch::Routing::RouteSet.new

class AppSweeper < ActionController::Caching::Sweeper

  def around_save(record)
    yield :in_around_save
  end

end

class SweeperTestController < ActionController::Base
  include SharedTestRoutes.url_helpers

  cache_sweeper :app_sweeper

  def show
    render plain: 'hello world'
  end

  def error
    raise StandardError.new
  end
end

class SweeperTest < ActionController::TestCase
  def setup
    @routes = SharedTestRoutes

    @routes.draw do
      get 'sweeper_test/show'
      get 'sweeper_test/error'
    end

    super
  end

  def test_sweeper_should_not_ignore_no_method_error
    sweeper = ActionController::Caching::Sweeper.send(:new)
    assert_raise NoMethodError do
      sweeper.send_not_defined
    end
  end

  def test_sweeper_should_not_respond_to_update_if_controller_is_not_set
    sweeper = AppSweeper.send(:new)
    yielded_value = nil
    sweeper.update(:around_save, Object.new) do |val|
      yielded_value = val
    end
    assert_nil yielded_value
  end

  def test_sweeper_should_respond_to_update_if_controller_is_set
    sweeper = AppSweeper.send(:new)
    sweeper.controller = SweeperTestController.new
    yielded_value = nil
    sweeper.update(:around_save, Object.new) do |val|
      yielded_value = val
    end
    assert_equal :in_around_save, yielded_value
  end

  def test_sweeper_should_not_block_rendering
    response = test_process(SweeperTestController)
    assert_equal 'hello world', response.body
  end

  def test_sweeper_should_clean_up_if_exception_is_raised
    assert_raise StandardError do
      test_process(SweeperTestController, 'error')
    end
    assert_nil AppSweeper.instance.controller
  end

  def test_before_method_of_sweeper_should_always_return_true
    sweeper = ActionController::Caching::Sweeper.send(:new)
    assert sweeper.before(SweeperTestController.new)
  end

  def test_after_method_of_sweeper_should_always_return_nil
    sweeper = ActionController::Caching::Sweeper.send(:new)
    assert_nil sweeper.after(SweeperTestController.new)
  end

  def test_sweeper_should_not_ignore_unknown_method_calls
    sweeper = ActionController::Caching::Sweeper.send(:new)
    assert_raise NameError do
      sweeper.instance_eval do
        some_method_that_doesnt_exist
      end
    end
  end

  private

  def test_process(controller, action = "show")
    @controller = controller.is_a?(Class) ? controller.new : controller
    if ActionController::TestRequest.respond_to?(:create)
      if ActionController::TestRequest.method(:create).arity == 0
        @request    = ActionController::TestRequest.create
      else
        @request    = ActionController::TestRequest.create @controller.class
      end
    else
      @request    = ActionController::TestRequest.new
    end
    if ActionController.constants.include?(:TestResponse)
      @response   = ActionController::TestResponse.new
    else
      @response   = ActionDispatch::TestResponse.new
    end

    process(action)
  end
end
