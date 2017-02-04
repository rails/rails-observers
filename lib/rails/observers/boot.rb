module Rails
  module Observers
    class Boot < Bootstrapper
      initialize :active_record, :before => 'active_record.set_configs' do |base, app|
        base.prepend ::ActiveRecord::Observing
      end

      initialize :action_controller do |base, app|
        base.extend ::ActionController::Caching::Sweeping::ClassMethods
      end

      initialize :active_resource do |base, app|
        base.prepend ::ActiveResource::Observing
      end

    end
  end
end
