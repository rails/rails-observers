require 'minitest/autorun'
require 'active_resource'
require 'rails/observers/active_resource/observing'

ActiveResource::Base.prepend ActiveResource::Observing

require 'active_support/core_ext/hash/conversions'

class Person < ActiveResource::Base
  self.site = "http://37s.sunrise.i:3000"
end

class ActiveResourceObservingTest < ActiveSupport::TestCase
  cattr_accessor :history

  class PersonObserver < ActiveModel::Observer
    observe :person

    callbacks = [
      :after_create,
      :after_create_commit,
      :after_destroy,
      :after_destroy_commit,
      :after_save,
      :after_update,
      :after_update_commit,
      :before_create,
      :before_destroy,
      :before_save,
      :before_update
    ]

    callbacks.each do |method|
      define_method(method) { |*| log method }
    end

    private
      def log(method)
        (ActiveResourceObservingTest.history ||= []) << method.to_sym
      end
  end

  def setup
    @matz = { 'person' => { :id => 1, :name => 'Matz' } }.to_json

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get    "/people/1.json", {}, @matz
      mock.post   "/people.json",   {}, @matz, 201, 'Location' => '/people/1.json'
      mock.put    "/people/1.json", {}, nil, 204
      mock.delete "/people/1.json", {}, nil, 200
    end

    PersonObserver.instance
  end

  def teardown
    self.history = nil
  end

  def test_create_fires_save_and_create_notifications
    Person.create(:name => 'Rick')

    if Rails.version.starts_with? '4.2'
      assert_equal [:before_save, :before_create, :after_create, :after_save], self.history
    else
      assert_equal [:before_save, :before_create, :after_create, :after_create_commit, :after_save], self.history
    end
  end

  def test_update_fires_save_and_update_notifications
    person = Person.find(1)
    person.save

    if Rails.version.starts_with? '4.2'
      assert_equal [:before_save, :before_update, :after_update, :after_save], self.history
    else
      assert_equal [:before_save, :before_update, :after_update, :after_update_commit, :after_save], self.history
    end
  end

  def test_destroy_fires_destroy_notifications
    person = Person.find(1)
    person.destroy

    if Rails.version.starts_with? '4.2'
      assert_equal [:before_destroy, :after_destroy], self.history
    else
      assert_equal [:before_destroy, :after_destroy, :after_destroy_commit], self.history
    end
  end
end
