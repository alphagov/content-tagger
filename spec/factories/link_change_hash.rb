FactoryGirl.define do
  factory :link_change, class: Hash do
    sequence :id, 1, &:to_s

    sequence :source, 1 do |n|
      { title: "source title #{n}",
        base_path: "source/base/path/#{n}",
        content_id: SecureRandom.uuid }
    end
    sequence :target, 1 do |n|
      { title: "target title #{n}",
        base_path: "target/base/path/#{n}",
        content_id: SecureRandom.uuid }
    end
    link_type 'taxons'
    change 'add'
    user_uid { SecureRandom.uuid }
    created_at { Time.current }

    initialize_with { attributes.deep_stringify_keys }
  end
end
