module Rails
  module Observers
    class Bootstrapper
      class << self

        def self.inherited(subclass)
        end

        mattr_reader :reloader_class do
          begin
            ::ActiveSupport::Reloader 
          rescue NameError 
            ::ActionDispatch::Reloader
          end
        end

        cattr_reader :railtie_class do
          'Rails::Railtie'.safe_constantize
        end

        def railtie
          return @railtie if defined?(@railtie)
          if railtie_class
            @railtie = Class.new(railtie_class)
            @railtie.railtie_name self.name
          else
            @railtie = nil
          end
          @railtie
        end

        def railtie?
          !railtie.nil?
        end

        def on_load_wrapper(orm, &block)
          orm = orm.to_s.underscore.to_sym
          Object.instance_exec(orm, block) do |orm_sym, unhooked_block|
            Proc.new do
              ::ActiveSupport.on_load(orm_sym) do
                app = ::Rails.application rescue nil
                self.instance_exec(self, app, &unhooked_block)
              end
            end
          end
        end

        def on_load(orm, &block)
          on_load_wrapper(orm, &block).yield
        end

        def initialize(orm, config = nil, &block)
          load_hooked_block = on_load_wrapper(orm, &block)
          if railtie?
            args = [ "#{orm}.observing" ]
            args << config unless config.blank?
            railtie.initializer(*args, &load_hooked_block)
          else
            load_hooked_block.yield
          end
        end

        def post_initialize(orm, &block)
          load_hooked_block = on_load_wrapper(orm) do |*args|
            reloader_class.to_prepare(*args, &block)
            block.yield(*args)
          end
          if railtie?
            railtie.config.after_initialize(&load_hooked_block)
          else
            load_hooked_block.yield
          end
        end

        #def self.delegate_to_railtie(*del_methods)
          #opts = { :to => :@railtie, :prefix => :railtie, :allow_nil => true }
          #del_methods.flatten!
          #opts.merge!(del_methods.extract_options!)
          #del_methods = del_methods.reject(&:blank?).map(&:to_sym).uniq
          #del_methods -= self.instance_methods(true)
          #delegate(*del_methods, opts) unless del_methods.empty?
        #end

        #delegate_to_railtie :railtie_name, :prefix => false
        #delegate_to_railtie :config, :rake_tasks, :console, :runner, :generators

      end
    end
  end
end
