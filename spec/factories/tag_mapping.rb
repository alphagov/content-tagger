FactoryGirl.define do
  factory :tag_mapping do
    content_base_path 'a/base/path'
    link_content_id 'a-content-id'
    link_type 'taxon'
    tagging_spreadsheet
    state 'ready_to_tag'
  end
end
