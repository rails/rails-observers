require 'minitest/autorun'
require 'active_record'
require 'rails/version'
require 'rails/observers/active_model/observing'
require 'rails/observers/activerecord/observer'

class ActiveRecordObservingTest < ActiveSupport::TestCase
  def test_observers_have_correct_callbacks
    expected_callbacks = ActiveRecord::Callbacks::CALLBACKS.dup
    if Rails.version >= '5'
      expected_callbacks.push(:after_create_commit, :after_update_commit, :after_destroy_commit)
    end
    assert_equal expected_callbacks, ActiveRecord::Observer::CALLBACKS
  end
end
