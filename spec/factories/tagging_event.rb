FactoryGirl.define do
  factory :tagging_event do
    taxon_content_id { SecureRandom.uuid }
    taxon_title 'Test taxon title'
    taggable_content_id { SecureRandom.uuid }
    taggable_title 'Test taggable title'
    user_uid { SecureRandom.uuid }
    tagged_on { 1.week.ago }
    tagged_at { DateTime.now - 1.week }
    change 1
  end
end
