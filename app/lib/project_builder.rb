class ProjectBuilder
  def self.call(name:, taxonomy_branch_content_id:, content_item_attributes_enum:)
    project = ProjectContentItem.transaction do
      Project
        .create!(name: name, taxonomy_branch: taxonomy_branch_content_id)
        .tap do |project|
          content_item_attributes_enum.each do |content_item_attributes|
            ProjectContentItem.create!(
              { project: project }.merge(content_item_attributes)
            )
          end
        end
    end

    project.content_items.each do |content_item|
      LookupContentIdWorker.perform_async(content_item.id)
    end
  end
end
