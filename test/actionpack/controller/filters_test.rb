class FilterTest < ActionController::TestCase
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
end

