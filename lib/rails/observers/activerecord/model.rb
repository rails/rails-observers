require 'rails/observers/active_model/active_model'

module ActiveRecord
  module Model
    included do
      extend ActiveModel::Observing::ClassMethods
      include ActiveModel::Observing
    end
  end

  class Base
    extend ActiveModel::Observing::ClassMethods
    include ActiveModel::Observing
  end
end
