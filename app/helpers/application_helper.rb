module ApplicationHelper
  def state_label_for(label_type:, title:)
    css_class = ['label', label_type].join(' ')

    content_tag :span, class: css_class do
      title
    end
  end

  def expanded_link_label(expanded_link)
    label_type = expanded_link.state == 'draft' ? 'warning' : 'success'

    state_label_for(
      label_type: "label-#{label_type}",
      title: expanded_link.state
    )
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
