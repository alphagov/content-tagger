FactoryGirl.define do
  factory :project do
    name 'project title'

    trait :with_content_items do
      content_items { build_list :project_content_item, 3 }
    end
  end
end
