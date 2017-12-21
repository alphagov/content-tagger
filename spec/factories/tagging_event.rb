FactoryGirl.define do
  factory :tagging_event do
    taxon_content_id { SecureRandom.uuid }
    taxon_title 'Test taxon title'
    taggable_content_id { SecureRandom.uuid }
    taggable_title 'Test taggable title'
    taggable_base_path '/some/example'
    taggable_navigation_document_supertype 'other'
    user_uid { SecureRandom.uuid }
    tagged_on { 1.week.ago }
    tagged_at { Time.current - 1.week }
    change 1

    trait :guidance do
      taggable_navigation_document_supertype 'guidance'
    end
  end
end
