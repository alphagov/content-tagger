class PermissionChecker
  GDS_EDITOR_PERMISSION = "gds_editor".freeze
  TAGATHON_PARTICIPANT_PERMISSION = "tagathon_participant".freeze

  def initialize(user)
    @user = user
  end

  def user_can_access_application?
    gds_editor? || tagathon_participant?
  end

  def user_can_administer_taxonomy?
    gds_editor?
  end

  def user_can_access_tagathon_tools?
    gds_editor? || tagathon_participant?
  end

private

  attr_reader :user

  def gds_editor?
    user.has_permission?(GDS_EDITOR_PERMISSION)
  end

  def tagathon_participant?
    user.has_permission?(TAGATHON_PARTICIPANT_PERMISSION)
  end
end
