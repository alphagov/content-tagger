require "rails_helper"

RSpec.describe PermissionChecker do
  subject { described_class.new(user) }
  let(:user) { instance_double(User, has_permission?: false) }

  context "when the current_user has no special permissions" do
    it { is_expected.not_to have_permission(:user_can_administer_taxonomy?) }
    it { is_expected.not_to have_permission(:user_can_manage_taxonomy?) }
    it { is_expected.not_to have_permission(:user_can_access_tagathon_tools?) }
  end

  context "when the user has the Gds Editor permission" do
    before do
      allow(user)
        .to receive(:has_permission?)
        .with("GDS Editor")
        .and_return(true)
    end

    it { is_expected.to have_permission(:user_can_administer_taxonomy?) }
    it { is_expected.to have_permission(:user_can_manage_taxonomy?) }
    it { is_expected.to have_permission(:user_can_access_tagathon_tools?) }
  end

  context "when the user has the Managing Editor permission" do
    before do
      allow(user)
        .to receive(:has_permission?)
        .with("Managing Editor")
        .and_return(true)
    end
    it { is_expected.not_to have_permission(:user_can_administer_taxonomy?) }
    it { is_expected.to have_permission(:user_can_manage_taxonomy?) }
    it { is_expected.to have_permission(:user_can_access_tagathon_tools?) }
  end

  context "when the user has the Tagathon Participant permission" do
    before do
      allow(user)
        .to receive(:has_permission?)
        .with("Tagathon participant")
        .and_return(true)
    end

    it { is_expected.not_to have_permission(:user_can_administer_taxonomy?) }
    it { is_expected.not_to have_permission(:user_can_manage_taxonomy?) }
    it { is_expected.to have_permission(:user_can_access_tagathon_tools?) }
  end
end
