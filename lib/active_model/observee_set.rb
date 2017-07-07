require 'active_model'
module ActiveModel
  class ObserveeSet # aka Classes Observed by an Observer

    attr_reader :observer
    attr_reader :observees
    attr_predicate :observees
    def initialize(observer) #:nodoc:
      @observer = observer
      @observees ||= Set.new
    end

    def add(*new_models)
      new_models = new_models.flatten.map do |model|
        Observing::DeferredModelLoader.new(model)
      end.compact
      observees.merge(new_models)
    end
    alias_method :<<, :add
    alias_method :merge, :add

    def replace(*models)
      observees.clear
      add(*models)
    end
    alias_method :observees=, :replace

    def all
      observees.to_a.freeze
    end

    def loaded
      all.select(&:model_defined?).freeze
    end

    def pending
      all.reject(&:model_defined?).freeze
    end

  end
end
