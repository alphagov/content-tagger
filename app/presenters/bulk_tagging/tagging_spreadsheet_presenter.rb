module BulkTagging
  class TaggingSpreadsheetPresenter < SimpleDelegator
    def label_type
      {
        errored: 'label-danger',
        imported: 'label-success'
      }.fetch(state.to_sym, 'label-warning')
    end

    def state_title
      I18n.t("bulk_tagging.state.#{state}")
    end

    def errored?
      state == 'errored'
    end
  end
end
