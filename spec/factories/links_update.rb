FactoryGirl.define do
  factory :links_update do
    base_path '/a/base/path'
    links {}
    tag_mappings TagMapping.none
  end
end
