class TagMigrationPresenter < SimpleDelegator
  def label_type
    {
      imported: 'label-success'
    }.fetch(state.to_sym, 'label-warning')
  end

  def state_title
    I18n.t("bulk_tagging.state.#{state}")
  end
end
