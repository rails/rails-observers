module ActionController #:nodoc:
  module Caching

    eager_autoload do
      autoload :Sweeper, 'action_controller/caching/sweeping'
      autoload :Sweeping, 'action_controller/caching/sweeping'
    end

    include Sweeping if defined?(ActiveRecord)
  end
end
