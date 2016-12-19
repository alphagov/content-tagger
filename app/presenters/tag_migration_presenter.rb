class TagMigrationPresenter < SimpleDelegator
  def label_type
    {
      imported: 'label-success'
    }.fetch(state.to_sym, 'label-warning')
  end

  def state_title
    case state
    when "ready_to_import" then "Tagging incomplete"
    when "imported" then "Tagging completed"
    when "errored" then "Errored"
    end
  end
end
