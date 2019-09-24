FactoryBot.define do
  factory :taxon_hash, class: Hash do
    sequence :title, 1 do |n|
      "taxon_title_#{n}"
    end
    content_id { SecureRandom.uuid }
    sequence :base_path, 1 do |n|
      "/path/#{n}"
    end
    sequence :description, 1 do |n|
      "this is taxon #{n}"
    end
    document_type { "taxon" }
    publication_state { "published" }

    transient do
      internal_name { nil }
      expanded_links { nil }
      links { {} }
    end

    initialize_with { attributes }

    trait :home_page do
      base_path { "/" }
      description { "" }
      details { {} }
      document_type { "homepage" }
      title { "GOV.UK homepage" }
      content_id { GovukTaxonomy::ROOT_CONTENT_ID }
    end

    after(:build) do |taxon, evaluator|
      taxon[:details] = { internal_name: evaluator.internal_name || "i-#{evaluator.title}" }
      taxon[:expanded_links] = evaluator.expanded_links unless evaluator.expanded_links.nil?
      taxon[:links] = evaluator.links
      taxon.deep_stringify_keys!
    end
  end
end
