class CalloutPresenter
  attr_reader :title, :page_type, :callout_class, :callout_title

  def initialize(title:, page_type:nil)
    @title = title
    @page_type = page_type

    configure_callout
  end

  def should_render?
    page_type.present?
  end

private

  def configure_callout
    case page_type
    when :new
      @callout_class = 'callout-info'
      @callout_title = I18n.t('views.callout_new')
    when :edit
      @callout_class = 'callout-warning'
      @callout_title = I18n.t('views.callout_edit')
    end
  end
end
