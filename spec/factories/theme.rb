FactoryGirl.define do
  factory :theme do
    name 'A theme'
    path_prefix '/foo'

    trait :education do
      name 'Education'
      path_prefix '/education'
    end
  end
end
