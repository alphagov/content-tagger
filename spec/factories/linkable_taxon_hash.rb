FactoryBot.define do
  factory :linkable_taxon_hash, class: Hash do
    sequence :title, 1 do |n|
      "Title of Taxon #{n}"
    end
    sequence :content_id, 1 do |n|
      "ID-#{n}"
    end
    sequence :base_path, 1 do |n|
      "/education/#{n}"
    end
    sequence :internal_name, 1 do |n|
      "Internal name of Taxon #{n}"
    end
    publication_state { "published" }

    initialize_with { attributes }
  end
end
