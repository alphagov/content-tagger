RSpec.describe ProjectsController do
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
      stub_draft_taxonomy_branch
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
end
