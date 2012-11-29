# Note:
# It is important to keep this file as light as possible
# the goal for tests that require this is to test booting up
# rails from an empty state, so anything added here could
# hide potential failures
#
# It is also good to know what is the bare minimum to get
# Rails booted up.
require 'fileutils'

require 'bundler/setup'
require 'minitest/autorun'
require 'active_support/test_case'

# These files do not require any others and are needed
# to run the tests
require "active_support/testing/isolation"
require "active_support/core_ext/kernel/reporting"
require 'tmpdir'

module TestHelpers
  module Paths
    def app_template_path
      File.join Dir.tmpdir, 'app_template'
    end

    def tmp_path(*args)
      @tmp_path ||= File.realpath(Dir.mktmpdir)
      File.join(@tmp_path, *args)
    end

    def app_path(*args)
      tmp_path(*%w[app] + args)
    end

    def rails_root
      app_path
    end
  end

  module Generation
    # Build an application by invoking the generator and going through the whole stack.
    def build_app(options = {})
      @prev_rails_env = ENV['RAILS_ENV']
      ENV['RAILS_ENV'] = 'development'

      FileUtils.rm_rf(app_path)
      FileUtils.cp_r(app_template_path, app_path)

      # Delete the initializers unless requested
      unless options[:initializers]
        Dir["#{app_path}/config/initializers/*.rb"].each do |initializer|
          File.delete(initializer)
        end
      end

      gemfile_path = "#{app_path}/Gemfile"
      if options[:gemfile].blank? && File.exist?(gemfile_path)
        File.delete gemfile_path
      end

      routes = File.read("#{app_path}/config/routes.rb")
      if routes =~ /(\n\s*end\s*)\Z/
        File.open("#{app_path}/config/routes.rb", 'w') do |f|
          f.puts $` + "\nmatch ':controller(/:action(/:id))(.:format)', :via => :all\n" + $1
        end
      end

      add_to_config <<-RUBY
        config.secret_token = "3b7cd727ee24e8444053437c36cc66c4"
        config.session_store :cookie_store, :key => "_myapp_session"
        config.active_support.deprecation = :log
        config.action_controller.allow_forgery_protection = false
        config.eager_load = false
      RUBY
    end

    def teardown_app
      ENV['RAILS_ENV'] = @prev_rails_env if @prev_rails_env
    end

    def add_to_config(str)
      environment = File.read("#{app_path}/config/application.rb")
      if environment =~ /(\n\s*end\s*end\s*)\Z/
        File.open("#{app_path}/config/application.rb", 'w') do |f|
          f.puts $` + "\n#{str}\n" + $1
        end
      end
    end

    def app_file(path, contents)
      FileUtils.mkdir_p File.dirname("#{app_path}/#{path}")
      File.open("#{app_path}/#{path}", 'w') do |f|
        f.puts contents
      end
    end

    def boot_rails
      require 'rubygems' unless defined? Gem
      require 'bundler'
      Bundler.setup
    end
  end
end

class ActiveSupport::TestCase
  include TestHelpers::Paths
  include TestHelpers::Generation
end

Module.new do
  extend TestHelpers::Paths

  # Build a rails app
  FileUtils.rm_rf(app_template_path)
  FileUtils.mkdir(app_template_path)

  `rails new #{app_template_path} --skip-gemfile`
end
