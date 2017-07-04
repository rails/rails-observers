require 'minitest/autorun'
require 'mocha/mini_test'
require 'active_record'
require 'rails'
require 'rails/observers/activerecord/active_record'

FIXTURES_ROOT = File.expand_path(File.dirname(__FILE__)) + "/fixtures"

module Rails
  class << self
    def version_matches?(requirement_str)
      ver = Gem::Version.new(version)
      req = Gem::Requirement.new(requirement_str)
      req.satisfied_by?(ver)
    end
  end
end

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures

  self.test_order = :random if self.respond_to?(:test_order=)
  self.fixture_path = FIXTURES_ROOT
  self.use_instantiated_fixtures  = false
  self.use_transactional_fixtures = true if Rails.version_matches?('~> 4.0')
  self.use_transactional_tests = true if self.respond_to?(:use_transactional_tests=)
end

if ActiveRecord::Base.respond_to?(:raise_in_transactional_callbacks=) && Rails.version_matches?('~> 4.0')
  ActiveRecord::Base.raise_in_transactional_callbacks = true
end

ActiveRecord::Base.configurations = { 'test' => { 'adapter' => 'sqlite3', 'database' => ':memory:' } }
ActiveRecord::Base.establish_connection(:test)

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :topics do |t|
    t.string   :title
    t.string   :author_name
    t.string   :author_email_address
    t.datetime :written_on
    t.time     :bonus_time
    t.date     :last_read
    t.text     :content
    t.text     :important
    t.boolean  :approved, :default => true
    t.integer  :replies_count, :default => 0
    t.integer  :parent_id
    t.string   :parent_title
    t.string   :type
    t.string   :group
    t.timestamps :null => false
  end

  create_table :comments do |t|
    t.string :title
  end

  create_table :minimalistics do |t|
  end

  create_table :developers do |t|
    t.string :name
    t.integer :salary
  end
end

class Topic < ActiveRecord::Base
  has_many :replies, dependent: :destroy, foreign_key: "parent_id"
end

class Reply < Topic
  belongs_to :topic, :foreign_key => "parent_id", :counter_cache => true
end

class Comment < ActiveRecord::Base
  def self.lol
    "lol"
  end
end

class Developer < ActiveRecord::Base
end

class Minimalistic < ActiveRecord::Base
end
