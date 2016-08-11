module ApplicationHelper
  def state_label_for(label_type:, title:, data_attributes:)
    css_class = ['label', label_type].join(' ')

    content_tag :span, class: css_class, data: data_attributes do
      title
    end
  end

  def time_tag_for(date)
    data_attributes = {
      'toggle': 'tooltip',
      'original-title': date,
    }

    content_tag :time, data: data_attributes do
      distance_of_time_in_words_to_now(date)
    end
  end
end
