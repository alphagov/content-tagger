require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  include RemoteCsvHelper
  include TaxonomyHelper

  describe "#index" do
    it "gets projects" do
      stub_draft_taxonomy_branch
      create(:project)
      get :index
      expect(response.code).to eql "200"
    end
  end

  describe "#show" do
    it "shows a project" do
      project = create(:project)
      get :show, params: { id: project.id }
      expect(response.code).to eql "200"
    end
  end

  describe "#new" do
    it "shows a new project form" do
      get :new
      expect(response.code).to eql "200"
    end
  end

  describe "#create" do
    it "creates a new (empty) project" do
      stub_remote_csv
      stub_draft_taxonomy_branch
      allow(LookupContentIdWorker).to receive(:perform_async)
      post :create, params: { new_project_form: { name: 'myproject', taxonomy_branch: valid_taxon_uuid, remote_url: RemoteCsvHelper::CSV_URL } }
      expect(response).to redirect_to projects_path
    end

    it "fails validation and rerenders the page" do
      post :create, params: { new_project_form: { name: 'myproject', remote_url: 'invalid' } }
      expect(response.code).to eql "200"
    end

    it "encounters an error in reading the URL and rerenders the page" do
      stub_request(:get, 'http://invalid_url').to_raise(SocketError)
      post :create, params: { new_project_form: { name: 'myproject', remote_url: 'http://invalid_url' } }
      expect(response.code).to eql "200"
    end
  end
end
