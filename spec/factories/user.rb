FactoryBot.define do
  factory :user do
    uid { SecureRandom.uuid }
    name "Sammy Hobson"
    permissions { ["signin"] }

    trait :gds_editor do
      permissions { ["signin", "GDS Editor"] }
    end

    trait :tagathon_participant do
      permissions { ["signin", "Tagathon participant"] }
    end
  end
end
