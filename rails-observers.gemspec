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
  s.license     = 'MIT'

  s.files         = Dir["LICENSE", "README.md", "lib/**/*"]
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.2.2'

  s.add_dependency 'activemodel', '>= 4.2'

  s.add_development_dependency 'minitest',       '>= 5'
  s.add_development_dependency 'railties',       '>= 4.2'
  s.add_development_dependency 'activerecord',   '>= 4.2'
  s.add_development_dependency 'actionmailer',   '>= 4.2'
  s.add_development_dependency 'actionpack',     '>= 4.2'
  s.add_development_dependency 'activeresource', '>= 4.0'
  s.add_development_dependency 'sqlite3',        '>= 1.3'
end
