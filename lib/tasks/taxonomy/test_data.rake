namespace :test_data do
  desc "Add a single taxon"
  task add_taxon: [:environment] do
    taxon_payload = build_taxon_payload

    taxon_links = {
      links: {
        root_taxon: [govuk_homepage_taxon_id],
      },
    }

    Services.publishing_api.put_content(taxon_content_id, taxon_payload)
    Services.publishing_api.patch_links(taxon_content_id, taxon_links)
    Services.publishing_api.publish(taxon_content_id, nil, locale: "en")
  end

  desc "Add many taxons"
  task add_many_taxons: [:environment] do
    base_taxon_payload = build_taxon_payload
    base_taxon_links = {
      links: {
        root_taxon: [govuk_homepage_taxon_id],
      },
    }
    base_taxon_content_id = SecureRandom.uuid

    Services.publishing_api.put_content(base_taxon_content_id, base_taxon_payload)
    Services.publishing_api.patch_links(base_taxon_content_id, base_taxon_links)
    Services.publishing_api.publish(base_taxon_content_id, nil, locale: "en")

    (1..100).each do |i|
      taxon_content_id = SecureRandom.uuid.to_s
      taxon_payload = build_taxon_payload(suffix: i)
      taxon_links = {
        links: {
          root_taxon: [base_taxon_content_id],
        },
      }

      Services.publishing_api.put_content(taxon_content_id, taxon_payload)
      Services.publishing_api.patch_links(taxon_content_id, taxon_links)
      Services.publishing_api.publish(taxon_content_id, nil, locale: "en")

      puts "Added test taxon #{i}"
    end
  end

  desc "Add test answer edition"
  task add_test_answer_edition: [:environment] do
    document_content_id = "4fcfb16d-3483-484d-911d-b2c7802d754d"
    document_payload = {
      base_path: "/test-answer-document",
      document_type: "answer",
      schema_name: "answer",
      title: "Test answer",
      description: "Test answer document with tagging for locally testing Content Tagger",
      publishing_app: "publisher",
      rendering_app: "frontend",
      public_updated_at: Time.zone.local(1985, 7, 24, 1, 2, 3).iso8601,
      routes: [
        { path: "/test-answer-document", type: "exact" },
      ],
      details: {
        body: [
          {
            content_type: "text/govspeak",
            content: "##This is an H2",
          },
        ],
        external_related_links: [
          {
            url: "https://www.gov.uk/test-answer-document",
            title: "Test answer document",
          },
        ],
      },
      locale: "en",
      update_type: "major",
      phase: "live",
    }

    taxon_link = {
      links: {
        taxons: [taxon_content_id],
      },
    }

    Services.publishing_api.put_content(document_content_id, document_payload)
    Services.publishing_api.patch_links(document_content_id, taxon_link)
    Services.publishing_api.publish(document_content_id, nil, locale: "en")
  end
end

def taxon_content_id
  "2ddc96b9-f5e3-4321-87b3-2930c60ea2b9"
end

def govuk_homepage_taxon_id
  "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a"
end

def build_taxon_payload(suffix: nil)
  base_path = "/test-taxon"
  base_path += "/test-taxon-#{suffix}" if suffix

  {
    base_path:,
    document_type: "taxon",
    schema_name: "taxon",
    title: "Test taxon #{suffix}",
    description: "Test taxon #{suffix} description",
    publishing_app: "content-tagger",
    rendering_app: "collections",
    public_updated_at: Time.zone.local(1985, 7, 24, 1, 2, 3).iso8601,
    locale: "en",
    details: {
      internal_name: "Test taxon #{suffix}",
      visible_to_departmental_editors: true,
    },
    routes: [
      { path: base_path, type: "exact" },
    ],
    update_type: "major",
    phase: "live",
  }
end
