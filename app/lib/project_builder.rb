class ProjectBuilder
  def self.call(project_name, content_item_attributes_enum)
    ProjectContentItem.transaction do
      Project.create!(name: project_name).tap do |project|
        content_item_attributes_enum.each do |content_item_attributes|
          ProjectContentItem.create!(
            { project: project }.merge(content_item_attributes)
          )
        end
      end
    end
  end
end
