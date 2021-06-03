class PermissionChecker
  GDS_EDITOR_PERMISSION = "GDS Editor".freeze
  TAGATHON_PARTICIPANT_PERMISSION = "Tagathon participant".freeze
  MANAGING_EDITOR_PERMISSION = "Managing Editor".freeze
  UNRELEASED_FEATURE_PERMISSION = "Unreleased feature".freeze

  def initialize(user)
    @user = user
  end

  def user_can_administer_taxonomy?
    gds_editor?
  end

  def user_can_manage_taxonomy?
    gds_editor? || managing_editor?
  end

  def user_can_access_tagathon_tools?
    gds_editor? || managing_editor? || tagathon_participant?
  end

  def user_can_override_taxon_url?
    user_can_administer_taxonomy? && unreleased_feature_editor?
  end

private

  attr_reader :user

  def gds_editor?
    user.has_permission?(GDS_EDITOR_PERMISSION)
  end

  def managing_editor?
    user.has_permission?(MANAGING_EDITOR_PERMISSION)
  end

  def tagathon_participant?
    user.has_permission?(TAGATHON_PARTICIPANT_PERMISSION)
  end

  def unreleased_feature_editor?
    user.has_permission?(UNRELEASED_FEATURE_PERMISSION)
  end
end
