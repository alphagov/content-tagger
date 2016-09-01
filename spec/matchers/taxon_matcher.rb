RSpec::Matchers.define :taxon_with_attributes do |expected|
  match do |actual|
    actual.title == expected[:title] &&
      actual.base_path == expected[:base_path] &&
      actual.content_id == expected[:content_id]
  end

  description do
    "an object with attributes #{expected}"
  end
end
