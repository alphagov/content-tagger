FactoryBot.define do
  factory :tag_mapping, class: BulkTagging::TagMapping do
    link_title { 'A taxon title' }
    content_base_path { 'a/base/path' }
    link_content_id { 'a-content-id' }
    link_type { 'taxons' }
    association :tagging_source, factory: :tagging_spreadsheet
    state { 'ready_to_tag' }
  end
end
