# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rails/observers/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "rails-observers"
  s.authors     = ["Rafael Mendonça França", "Steve Klabnik"]
  s.email       = ["rafaelmfranca@gmail.com", "steve@steveklabnik.com"]
  s.description = %q{Rails observer (removed from core in Rails 4.0)}
  s.summary     = %q{ActiveModel::Observer, ActiveRecord::Observer and ActionController::Caching::Sweeper extracted from Rails.}
  s.homepage    = "https://github.com/rails/rails-observers"
  s.version     = Rails::Observers::VERSION

  s.files         = [".gitignore",".travis.yml","Gemfile","LICENSE","README.md","Rakefile","lib/generators/active_record/observer/observer_generator.rb","lib/generators/active_record/observer/templates/observer.rb","lib/generators/rails/observer/USAGE","lib/generators/rails/observer/observer_generator.rb","lib/generators/test_unit/observer/observer_generator.rb","lib/generators/test_unit/observer/templates/unit_test.rb","lib/rails-observers.rb","lib/rails/observers/action_controller/caching.rb","lib/rails/observers/action_controller/caching/sweeping.rb","lib/rails/observers/active_model.rb","lib/rails/observers/active_model/active_model.rb","lib/rails/observers/active_model/observer_array.rb","lib/rails/observers/active_model/observing.rb","lib/rails/observers/activerecord/active_record.rb","lib/rails/observers/activerecord/base.rb","lib/rails/observers/activerecord/observer.rb","lib/rails/observers/railtie.rb","lib/rails/observers/version.rb","rails-observers.gemspec","rails-observers.gemspec.erb","test/configuration_test.rb","test/console_test.rb","test/fixtures/developers.yml","test/fixtures/minimalistics.yml","test/fixtures/topics.yml","test/generators/generators_test_helper.rb","test/generators/namespaced_generators_test.rb","test/generators/observer_generator_test.rb","test/helper.rb","test/isolation/abstract_unit.rb","test/lifecycle_test.rb","test/models/observers.rb","test/observer_array_test.rb","test/observing_test.rb","test/rake_test.rb","test/sweeper_test.rb","test/transaction_callbacks_test.rb"]
  s.test_files    = ["test/configuration_test.rb","test/console_test.rb","test/fixtures/developers.yml","test/fixtures/minimalistics.yml","test/fixtures/topics.yml","test/generators/generators_test_helper.rb","test/generators/namespaced_generators_test.rb","test/generators/observer_generator_test.rb","test/helper.rb","test/isolation/abstract_unit.rb","test/lifecycle_test.rb","test/models/observers.rb","test/observer_array_test.rb","test/observing_test.rb","test/rake_test.rb","test/sweeper_test.rb","test/transaction_callbacks_test.rb"]
  s.executables   = []
  s.require_paths = ["lib"]

  s.add_dependency 'activemodel', '~> 4.0'

  s.add_development_dependency 'minitest',     '>= 3'
  s.add_development_dependency 'railties', '~> 4.0'
  s.add_development_dependency 'activerecord', '~> 4.0'
  s.add_development_dependency 'actionmailer', '~> 4.0'
  s.add_development_dependency 'actionpack', '~> 4.0'
  s.add_development_dependency 'sqlite3',      '~> 1.3'
end
