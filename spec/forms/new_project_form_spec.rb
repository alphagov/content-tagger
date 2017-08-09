require 'rails_helper'

RSpec.describe NewProjectForm do
  include RemoteCsvHelper
  include TaxonomyHelper

  before { stub_remote_csv }

  let(:valid_params) do
    {
      name: 'my_name',
      remote_url: RemoteCsvHelper::CSV_URL,
      taxonomy_branch: valid_taxon_uuid
    }
  end

  describe '#create' do
    context 'with a valid form' do
      it 'returns the Project' do
        valid_form = NewProjectForm.new(valid_params)
        expect(valid_form.create).to be_a Project
      end

      it 'persists the Project' do
        valid_form = NewProjectForm.new(valid_params)
        expect { valid_form.create }.to change { Project.count }.by(1)
      end
    end

    context 'when the form is invalid' do
      it 'returns false' do
        invalid_form = NewProjectForm.new
        allow(invalid_form).to receive(:valid?).and_return false
        expect(invalid_form.create).to be false
      end
    end

    context 'with an exploding CSV' do
      it 'returns false' do
        allow_any_instance_of(RemoteCsv)
          .to receive(:to_enum)
          .and_raise(SocketError)
        params = valid_params.merge(remote_url: 'http://invalid.url')
        invalid_form = NewProjectForm.new(params)
        expect(invalid_form.create).to be false
      end
    end
  end

  describe "#valid?" do
    context 'with an invalid CSV URL' do
      it 'returns false' do
        params = valid_params.merge(remote_url: 'not.a.url')
        invalid_form = NewProjectForm.new(params)
        expect(invalid_form.valid?).to be false
      end
    end

    context 'without a chosen taxonomy_branch' do
      it 'returns false' do
        params = valid_params.except(:taxonomy_branch)
        invalid_form = NewProjectForm.new(params)
        expect(invalid_form.valid?).to be false
      end
    end

    context 'without a name' do
      it 'returns false' do
        params = valid_params.except(:name)
        invalid_form = NewProjectForm.new(params)
        expect(invalid_form.valid?).to be false
      end
    end
  end

  describe "#taxonomy_branches_for_select" do
    before do
      allow_any_instance_of(GovukTaxonomy::Branches)
        .to receive(:all)
        .and_return(
          [
            {
              'status' => 'published',
              'title' => 'Published Title',
              'content_id' => 'published_id'
            },
            {
              'status' => 'draft',
              'title' => 'Draft Title',
              'content_id' => 'draft_id'
            }
          ]
        )
    end

    it 'returns a hash of title => id' do
      result = NewProjectForm.new.taxonomy_branches_for_select
      expect(result['Draft Title']).to eq 'draft_id'
    end

    it 'only returns draft root taxons' do
      result = NewProjectForm.new.taxonomy_branches_for_select
      expect(result.size).to eq 1
    end
  end
end
