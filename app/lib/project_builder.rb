class ProjectBuilder
  def self.call(project_name, taxonomy_branch_content_id, content_item_attributes_enum)
    ProjectContentItem.transaction do
      Project
        .create!(name: project_name, taxonomy_branch: taxonomy_branch_content_id)
        .tap do |project|
          content_item_attributes_enum.each do |content_item_attributes|
            content_item = ProjectContentItem.create!(
              { project: project }.merge(content_item_attributes)
            )
            LookupContentIdWorker.perform_async(content_item.id)
          end
        end
    end
  end
end
