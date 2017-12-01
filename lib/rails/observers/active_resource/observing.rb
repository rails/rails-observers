require 'rails/observers/active_model/observing'

module ActiveResource
  module Observing
    def self.prepended(context)
      context.include ActiveModel::Observing
    end

    def create(*)
      notify_observers(:before_create)
      if result = super
        notify_observers(:after_create)
        notify_observers(:after_create_commit)
      end
      result
    end

    def save(*)
      notify_observers(:before_save)
      if result = super
        notify_observers(:after_save)
      end
      result
    end

    def update(*)
      notify_observers(:before_update)
      if result = super
        notify_observers(:after_update)
        notify_observers(:after_update_commit)
      end
      result
    end

    def destroy(*)
      notify_observers(:before_destroy)
      if result = super
        notify_observers(:after_destroy)
        notify_observers(:after_destroy_commit)
      end
      result
    end
  end
end
