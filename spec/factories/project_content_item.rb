FactoryGirl.define do
  factory :project_content_item do
    url "MyString"
    title "MyString"
    description "MyString"
    content_id { SecureRandom.uuid }
  end
end
