module ActiveModel
  module Observing
    class DeferredModelLoader
      include Comparable
      extend ActiveSupport::DescendantsTracker
      class << self
        def load_all
          descendants.reject(&:loaded?).each(&:load!)
        end

        def load_if(&block)
          descendants.reject(&:loaded?).select(&block).each(&:load!)
        end
      end

      attr_reader :model_name
      def initialize(model_name)
        if [ Class, Module ].any? { |mod| model_name.is_a?(mod) }
          warn ArgumentError, "Specifying models to observe as classes " +
            "(as opposed to the stringy names of classes) is highly deprecated and " +
            "very likely to result in circular dependencies. (From observation of #{model} " +
            "by #{observer}.)"
          model_name = model_name.name
        elsif model_name.is_a?(self.class)
          model_name = model_name.name
        end

        if [ String, Symbol ].none? { |mod| model_name.is_a?(mod) }
        __raise__ ArgumentError, "Argument #{model_name} must be a String or Symbol."
        elsif !model_name.respond_to?(:to_s)
          __raise__ ArgumentError, "Argument #{model_name} must respond to #to_s."
        end
        @model_name = model_name.to_s.camelize.freeze
      end

      def <=>(other)
        self.model_name <=> other.model_name
      end

      def model_defined?
        Object.const_defined?(model_name)
      end

      def model_assigned?
        defined?(@model)
      end

      def model(load_model = false)
        return @model if model_assigned?
        return nil unless load_model || model_defined?
        @model = Object.const_get(model_name)
      end

    end
  end
end
