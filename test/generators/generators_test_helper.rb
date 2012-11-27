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
