require 'securerandom'

namespace :alternative_facts do
  desc "seed the tagging_events table with made up data"
  task seed: :environment do
    raise unless Rails.env.development?

    # invent some taxons
    taxons = (0..10).map do
      {
        content_title: Faker::Color.unique.color_name,
        content_id: SecureRandom.uuid
      }
    end

    # invent some content items
    content_items = (0..2000).map do
      {
        title: Faker::Lorem.sentence,
        id: SecureRandom.uuid
      }
    end

    # invent some users
    users = (0..100).map do
      {
        id: SecureRandom.uuid,
        email: Faker::Internet.unique.email
      }
    end

    # invent a date range
    period_starts = 100.days.ago
    period_ends = Date.yesterday

    # let's invent some facts
    10_000.times do
      taxon = taxons.sample
      content_item = content_items.sample
      user = users.sample
      timestamp = Faker::Time.between(period_starts, period_ends)

      TaggingEvent.create(
        taxon_content_id: taxon[:content_id],
        taxon_content_title: taxon[:content_title],
        content_id: content_item[:id],
        content_title: content_item[:title],
        user_id: user[:id],
        user_email: user[:email],
        tagged_on: timestamp.to_date,
        tagged_at: timestamp,
        change: [-1, 1].sample
      )
    end
  end
end
