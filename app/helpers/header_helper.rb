module HeaderHelper
  # Generates a header with `title` and `breadcrumbs`. Last item in the
  # breadcrumbs array should be a string for the "active" entry.
  def display_header(title:, breadcrumbs:, page_title: nil)
    breadcrumbs = breadcrumbs.compact
    active_item = breadcrumbs.pop

    locals = {
      title:,
      breadcrumbs:,
      page_title: page_title || title,
      active_item: active_item.try(:title) || active_item,
    }

    render(layout: "shared/header", locals:) do
      yield if block_given?
    end
  end

  def auto_link(object)
    if object.is_a?(ActiveRecord::Base)
      link_to object.title, object
    elsif object.to_s.starts_with?("<a href")
      raw object
    else
      link_to object.to_s.humanize, object.to_sym
    end
  end
end
