require "rails_helper"

RSpec.describe ProjectBuilder do
  before do
    allow(LookupContentIdWorker).to receive(:perform_async)
  end

  let(:project_name) { 'project_name' }
  let(:taxonomy_branch_content_id) { SecureRandom.uuid }
  let(:content_item_attributes_enum) { [] }
  let(:bulk_tagging_enabled) { false }

  def build_project(
    name: project_name,
    branch: taxonomy_branch_content_id,
    content_items: content_item_attributes_enum,
    bulk_tagging: bulk_tagging_enabled
  )

    ProjectBuilder.call(
      name: name,
      taxonomy_branch_content_id: branch,
      content_item_attributes_enum: content_items,
      bulk_tagging_enabled: bulk_tagging
    )
  end

  it 'creates a new project' do
    expect { build_project }
      .to change { Project.count }
            .by(1)
  end

  it 'creates two new content items' do
    expect { build_project(content_items: [{ title: 'one' }, { title: 'two' }]) }
      .to change { ProjectContentItem.count }
            .by(2)
  end

  it 'queues a request to lookup the content_id' do
    build_project(content_items: [{ id: 1 }])

    expect(LookupContentIdWorker)
      .to have_received(:perform_async)
      .with(1)
  end
end
