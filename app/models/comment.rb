class Comment < ActiveRecord::Base
  attr_accessible :comment
  validates_presence_of :comment
  belongs_to :daily
end
