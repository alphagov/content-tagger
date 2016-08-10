module ApplicationHelper
  def state_label_for(label_type:, title:, data_attributes:)
    css_class = ['label', label_type].join(' ')

    content_tag :span, class: css_class, data: data_attributes do
      title
    end
  end
end
