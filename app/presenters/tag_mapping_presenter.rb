class TagMappingPresenter < SimpleDelegator
  def label_type
    {
      errored: 'label-danger',
      tagged: 'label-success'
    }.fetch(state.to_sym, 'label-default')
  end

  def state_title
    state.humanize
  end

  def errored?
    state == 'errored'
  end
end
