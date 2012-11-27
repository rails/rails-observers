class Topic < ActiveRecord::Base
  has_many :replies, dependent: :destroy, foreign_key: "parent_id"
end

class Reply < Topic
  scope :base, -> { scoped }

  belongs_to :topic, :foreign_key => "parent_id", :counter_cache => true
end
