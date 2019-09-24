FactoryBot.define do
  factory :project do
    name { "project title" }

    # TaxonomyHelper.valid_taxon_uuid
    taxonomy_branch { "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa" }

    bulk_tagging_enabled { true }

    trait :with_content_items do
      content_items { build_list :project_content_item, 3 }
    end

    trait :with_content_item do
      content_items { build_list :project_content_item, 1 }
    end

    trait :with_a_content_item do
      content_items { build_list :project_content_item, 1 }
    end

    trait :with_bulk_tagging_disabled do
      bulk_tagging_enabled { false }
    end
  end
end
