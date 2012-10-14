module ActionController #:nodoc:
  module Caching
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Sweeper,  'rails/observers/action_controller/caching/sweeping'
      autoload :Sweeping, 'rails/observers/action_controller/caching/sweeping'
    end

    include Sweeping if defined?(ActiveRecord)
  end
end
