# frozen_string_literal: true

FactoryBot.define do
  factory :linked_content_item do
    title { "A linked content item" }
    content_id { SecureRandom.uuid }
    base_path { "/level-one/linked-content-base-path" }
    internal_name { "An internal name" }
  end
end
