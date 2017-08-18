require "rails_helper"

RSpec.describe ProjectBuilder do
  before do
    allow(LookupContentIdWorker).to receive(:perform_async)
  end

  it 'creates a new project' do
    expect { ProjectBuilder.call('project', '', []) }
      .to change { Project.count }
            .by(1)
  end

  it 'creates two new content items' do
    expect { ProjectBuilder.call('project', '', [{ title: 'one' }, { title: 'two' }]) }
      .to change { ProjectContentItem.count }
            .by(2)
  end

  it 'queues a request to lookup the content_id' do
    ProjectBuilder.call('project', '', [{ id: 1 }])

    expect(LookupContentIdWorker)
      .to have_received(:perform_async)
      .with(1)
  end
end
