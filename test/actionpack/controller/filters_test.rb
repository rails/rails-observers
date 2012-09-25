require 'minitest/autorun'
require 'action_controller'
require 'active_record-observers/activerecord/observer'
require 'active_record-observers/actionpack/action_controller/caching'

SharedTestRoutes = ActionDispatch::Routing::RouteSet.new

module ActionController
  class Base
    include SharedTestRoutes.url_helpers
  end
end

class FilterTest < ActionController::TestCase
  class TestController < ActionController::Base
    before_filter :ensure_login
    after_filter  :clean_up

    def show
      render :inline => "ran action"
    end

    private
      def ensure_login
        @ran_filter ||= []
        @ran_filter << "ensure_login"
      end

      def clean_up
        @ran_after_filter ||= []
        @ran_after_filter << "clean_up"
      end
  end

  class ::AppSweeper < ActionController::Caching::Sweeper; end

  class SweeperTestController < ActionController::Base
    cache_sweeper :app_sweeper
    def show
      render :text => 'hello world'
    end

    def error
      raise StandardError.new
    end
  end

  def setup
    @routes = SharedTestRoutes

    @routes.draw do
      get ':controller(/:action)'
    end

    super
  end

  def test_sweeper_should_not_ignore_no_method_error
    sweeper = ActionController::Caching::Sweeper.send(:new)
    assert_raise NoMethodError do
      sweeper.send_not_defined
    end
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
    assert sweeper.before(TestController.new)
  end

  def test_after_method_of_sweeper_should_always_return_nil
    sweeper = ActionController::Caching::Sweeper.send(:new)
    assert_nil sweeper.after(TestController.new)
  end

  private
    def test_process(controller, action = "show")
      @controller = controller.is_a?(Class) ? controller.new : controller
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new

      process(action)
    end
end

