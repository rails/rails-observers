module ActiveModel
  class DisabledObserversRegistry
    extend ActiveSupport::PerThreadRegistry

    attr_accessor :disabled_observers_per_class
    attr_accessor :disabled_observers_stacks_per_class

    def initialize
      @disabled_observers_per_class         = {}
      @disabled_observers_stacks_per_class  = {}
    end
  end
end