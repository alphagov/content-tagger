FactoryGirl.define do
  factory :taxon do
    title 'A taxon'
    parent_taxons []
    content_id 'taxon-content-id'
    base_path '/taxon-base-path'
    publication_state 'published'
    internal_name 'An internal name'
  end
end
