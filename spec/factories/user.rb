FactoryBot.define do
  factory :user do
    uid { SecureRandom.uuid }
    name { "Sammy Hobson" }
    permissions { %w[signin] }

    trait :gds_editor do
      permissions { ["signin", "GDS Editor"] }
    end

    trait :managing_editor do
      permissions { ["signin", "Managing Editor"] }
    end

    trait :tagathon_participant do
      permissions { ["signin", "Tagathon participant"] }
    end
  end
end
