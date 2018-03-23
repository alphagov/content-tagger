require 'rails_helper'

RSpec.describe NewProjectForm, '#create' do
  let(:valid_params) do
    {
      name: 'Project name',
      remote_url: "http://example.com/sheet.csv",
      taxonomy_branch: SecureRandom.uuid
    }
  end

  it 'returns true when the form is valid' do
    stub_request(:get, valid_params[:remote_url]).to_return(body: <<~CSV)
      url,title,description
      https://www.gov.uk/path,Title,Description
    CSV

    publishing_api_has_lookups('/path' => 'f838c22a-b2aa-49be-bd95-153f593293a3')

    form = NewProjectForm.new(valid_params)

    expect(form.create).to eq(true)
  end

  it 'returns false when a project name is not given' do
    form = NewProjectForm.new(valid_params.except(:name))

    expect(form.create).to eq(false)
  end

  it 'returns false when the CSV URL does not begin with http(s)' do
    form = NewProjectForm.new(valid_params.merge(remote_url: 'not a URL'))

    expect(form.create).to eq(false)
  end

  it 'returns false when a taxonomy_branch is not a UUID' do
    form = NewProjectForm.new(valid_params.merge(taxonomy_branch: 'not a UUID'))

    expect(form.create).to eq(false)
  end

  it 'returns false with an error added when the CSV fails to parse' do
    allow_any_instance_of(RemoteCsv)
      .to receive(:rows_with_headers)
      .and_raise(RemoteCsv::ParsingError.new(Net::OpenTimeout.new("execution expired")))

    form = NewProjectForm.new(valid_params)

    expect(form.create).to eq(false)
    expect(form.errors[:remote_url]).to include "Net::OpenTimeout: execution expired"
  end

  it 'returns false with an error added when the content items from the CSV are already imported' do
    create(:project_content_item, content_id: 'f838c22a-b2aa-49be-bd95-153f593293a3')

    stub_request(:get, valid_params[:remote_url]).to_return(body: <<~CSV)
      url,title,description
      https://www.gov.uk/path,Title,Description
    CSV

    publishing_api_has_lookups('/path' => 'f838c22a-b2aa-49be-bd95-153f593293a3')

    form = NewProjectForm.new(valid_params)

    expect(form.create).to eq(false)
    expect(form.errors[:base]).to include [/project was not created/, ["https://www.gov.uk/path"]]
  end
end

RSpec.describe NewProjectForm, '#taxonomy_branches_for_select' do
  include TaxonomyHelper

  before do
    allow_any_instance_of(GovukTaxonomy::Branches)
      .to receive(:all)
      .and_return(
        [
          {
            'title' => 'Title',
            'content_id' => 'content_id'
          }
        ]
      )
  end

  it 'returns a hash of title => id' do
    result = NewProjectForm.new.taxonomy_branches_for_select
    expect(result['Title']).to eq 'content_id'
  end
end
