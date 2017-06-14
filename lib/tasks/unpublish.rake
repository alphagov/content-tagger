namespace :unpublish do
  desc "Unpublish the content item related to the content api: /api"
  task content_api: :environment do
    content_id =
      Services.publishing_api.lookup_content_id(base_path: '/api')

    raise "Could not find content ID for '/api'." if content_id.nil?

    Services.publishing_api.unpublish(
      content_id,
      type: 'gone',
      explanation: "The Content API has been retired."
    )
  end
end
