RSpec.describe Taxonomy::HealthWarningsController, type: :controller do
  describe "GET #index" do
    it "returns a success response" do
      get :index, params: {}
      expect(response).to be_successful
    end
  end
end
