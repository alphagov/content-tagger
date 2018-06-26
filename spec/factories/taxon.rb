FactoryBot.define do
  factory :taxon do
    title 'A taxon'
    description 'A description'
    document_type 'taxon'
    parent_content_id nil
    content_id { SecureRandom.uuid }
    base_path '/level-one/taxon-base-path'
    publication_state 'published'
    internal_name 'An internal name'

    trait :draft do
      publication_state 'draft'
    end

    trait :previously_published_draft do
      publication_state 'draft'
      state_history do
        {
          "2" => "draft",
          "1" => "published"
        }
      end
    end

    factory :draft_taxon, traits: [:draft]
    factory :previously_published_draft_taxon, traits: [:previously_published_draft]
  end
end
