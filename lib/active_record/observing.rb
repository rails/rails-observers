require 'active_record'
module ActiveRecord
  module Observing
    def self.prepended(klass)
      klass.include ActiveModel::Observing
    end
  end
end
