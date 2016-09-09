FactoryGirl.define do
  factory :tag_migration do
    source_content_id 'original-content-id'
    source_base_path '/original-base-path'
    state 'ready_to_import'
    query 'a query'
  end
end
