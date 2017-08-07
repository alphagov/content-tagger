class Project < ActiveRecord::Base
  has_many :content_items, class_name: 'ProjectContentItem'
end
