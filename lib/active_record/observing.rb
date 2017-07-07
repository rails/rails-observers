require 'active_record'
module ActiveRecord
  module Observing
    def self.prepended(klass)
      klass.prepend ActiveModel::Observing
    end
  end
end
