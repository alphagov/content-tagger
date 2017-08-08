require "rails_helper"

RSpec.describe ProjectBuilder do
  it 'creates a new project' do
    expect { ProjectBuilder.call('project', []) }
      .to change { Project.count }
            .by(1)
  end
  it 'creates two new content items' do
    expect { ProjectBuilder.call('project', [{ title: 'one' }, { title: 'two' }]) }
      .to change { ProjectContentItem.count }
            .by(2)
  end
end
