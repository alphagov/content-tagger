FactoryGirl.define do
  factory :user do
    uid { SecureRandom.uuid }
    name "Sammy Hobson"
    permissions { ["signin"] }

    trait :gds_editor do
      permissions { %w(signin gds_editor) }
    end

    trait :tagathon_participant do
      permissions { %w(signin tagathon_participant) }
    end
  end
end
