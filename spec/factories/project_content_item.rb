FactoryBot.define do
  factory :project_content_item do
    url { "MyString" }
    title { "MyString" }
    description { "MyString" }
    content_id { SecureRandom.uuid }

    trait :flagged_needs_help do
      flag { ProjectContentItem.flags["needs_help"] }
    end

    trait :flagged_missing_topic do
      flag { ProjectContentItem.flags["missing_topic"] }
      suggested_tags { "have you thought about ...?" }
    end
  end
end
