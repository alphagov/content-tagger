FactoryGirl.define do
  factory :tag_migration do
    original_link_content_id 'original-content-id'
    original_link_base_path '/original-base-path'
    state 'ready_to_import'
    query 'a query'
  end
end
