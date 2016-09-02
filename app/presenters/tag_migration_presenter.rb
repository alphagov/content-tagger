class TagMigrationPresenter < SimpleDelegator
  def label_type
    {
      imported: 'label-success'
    }.fetch(state.to_sym, 'label-warning')
  end

  def state_title
    state.humanize
  end
end
