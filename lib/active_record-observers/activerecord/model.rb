module ActiveRecord
  module Model
    extend ActiveModel::Observing::ClassMethods

    included do
      include ActiveModel::Observing
    end
  end
end
