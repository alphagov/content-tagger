FactoryGirl.define do
  factory :taxon do
    title 'A taxon'
    description 'A description'
    parent_taxons []
    content_id 'taxon-content-id'
    base_path '/education/taxon-base-path'
    publication_state 'published'
    internal_name 'An internal name'
  end
end
