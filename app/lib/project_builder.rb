class ProjectBuilder
  def self.call(project_attributes:, content_item_attributes:)
    ActiveRecord::Base.transaction do
      project = Project.create!(project_attributes)
      project_content_items = project.content_items.new(content_item_attributes)

      content_ids = Services.publishing_api.lookup_content_ids(
        base_paths: project_content_items.map(&:base_path),
      )

      invalid_content_items = []

      project_content_items.each do |record|
        record.content_id = content_ids[record.base_path]

        if record.valid?
          record.save!
        else
          invalid_content_items << record
        end
      end

      if invalid_content_items.any?
        raise DuplicateContentItemsError, invalid_content_items
      end
    end
  end

  class DuplicateContentItemsError < StandardError
    attr_accessor :conflicting_items_urls

    def initialize(urls)
      super(message)
      @conflicting_items_urls = urls.pluck(:url)
    end

    def message
      <<~MSG
        The project was not created because the spreadsheet contains content
        that has already been imported to other projects.

        To resolve this, remove the following rows from the spreadsheet before
        creating the project again. Please note that it may take Google sheets
        up to 5 minutes for the changes to be republished to the CSV format.
      MSG
    end
  end
end
