FactoryGirl.define do
  factory :tag_migration do
    source_content_id 'original-content-id'
    state 'ready_to_import'
  end
end
