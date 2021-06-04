module GoogleSheetHelper
module_function

  def google_sheet_url(key:, gid:)
    "https://docs.google.com/spreadsheets/d/#{key}/pub?gid=#{gid}&single=true&output=csv"
  end

  def google_sheet_fixture(extra_rows = [])
    [
      google_sheet_row(content_base_path: "content_base_path", link_title: "link_title", link_content_id: "link_content_id", link_type: "link_type"),
      google_sheet_row(content_base_path: "/content-1/", link_title: "Education", link_content_id: "education-content-id", link_type: "taxons"),
      google_sheet_row(content_base_path: "/content-2/", link_title: "Early Years", link_content_id: "early-years-content-id", link_type: "taxons"),
    ].concat(extra_rows).join("\n")
  end

  def empty_google_sheet(with_rows: [])
    [
      google_sheet_row(content_base_path: "content_base_path", link_title: "link_title", link_content_id: "link_content_id", link_type: "link_type"),
    ].concat(with_rows).join("\n")
  end

  def google_sheet_row(content_base_path:, link_title:, link_content_id:, link_type:)
    [content_base_path, link_title, link_content_id, link_type].join(",")
  end

  def parsed_google_sheet
    CSV.parse(google_sheet_fixture, headers: true)
  end

  def google_sheet_content_items
    content_base_paths = parsed_google_sheet.map { |row| row["content_base_path"] }.uniq
    content_base_paths.each_with_object({}) do |base_path, hash|
      fake_content_id = "#{base_path.delete('/')}-cid"
      hash[base_path] = fake_content_id
    end
  end

  def google_sheet_content_items_with_draft
    items = google_sheet_content_items
    items["/content-2/"] = nil
    items
  end
end
