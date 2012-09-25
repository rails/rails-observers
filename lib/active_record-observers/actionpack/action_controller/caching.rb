module ActionController #:nodoc:
  module Caching

    eager_autoload do
      autoload :Sweeper,  'active_record-observers/actionpack/action_controller/caching/sweeping'
      autoload :Sweeping, 'active_record-observers/actionpack/action_controller/caching/sweeping'
    end

    include Sweeping if defined?(ActiveRecord)
  end
end
