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

    factory :draft_taxon, traits: [:draft]
  end
end
