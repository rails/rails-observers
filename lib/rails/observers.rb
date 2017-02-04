require 'byebug' if ENV.key?('BYEBUG')
require 'active_support/all'
require 'active_support/dependencies'

module Rails
  module Observers
    extend ActiveSupport::Autoload
    autoload :Boot
    autoload :Bootstrapper
    autoload :Deprecation
    autoload :Version
  end
end

module ActionController
  module Caching
    extend ActiveSupport::Autoload
    autoload :Sweeper
    autoload :Sweeping
  end
end

module ActiveModel
  extend ActiveSupport::Autoload
  autoload :ObserverArray
  autoload :Observer
  autoload :Observing
end

module ActiveRecord
  extend ActiveSupport::Autoload
  autoload :Observer
  autoload :Observing
end

module ActiveResource
  extend ActiveSupport::Autoload
  autoload :Observing
end

require 'rails/observers/boot'
