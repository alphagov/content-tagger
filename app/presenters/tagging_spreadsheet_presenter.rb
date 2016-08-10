class TaggingSpreadsheetPresenter < SimpleDelegator
  def label_type
    {
      errored: 'label-danger',
      imported: 'label-success'
    }.fetch(state.to_sym, 'label-warning')
  end

  def state_title
    state.humanize
  end

  def data_attributes
    return {} unless state == 'errored'

    {
      'toggle': 'tooltip',
      'original-title': error_message
    }
  end
end
