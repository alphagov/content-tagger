class TagMappingPresenter < SimpleDelegator
  def label_type
    {
      errored: 'label-danger',
      tagged: 'label-success'
    }.fetch(state.to_sym, 'label-warning')
  end

  def state_title
    state.humanize
  end

  def errored?
    state == 'errored'
  end

  def error_messages
    messages.split('.')
  end
end
