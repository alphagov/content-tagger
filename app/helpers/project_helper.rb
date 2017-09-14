module ProjectHelper
  def text_for_content_flagging_link(content_item)
    if content_item.flag?
      I18n.t('views.projects.flags_link.flagged')
    else
      I18n.t('views.projects.flags_link.not_flagged')
    end
  end
end
