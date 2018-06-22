require "rails_helper"

RSpec.describe "Taxonomy Health Warnings" do
  include ContentItemHelper
  include PublishingApiHelper

  scenario "Viewing the Taxonomy Health Warnings" do
    given_a_taxon
    given_a_health_warning
    when_i_visit_the_health_warnings_page
    then_i_see_the_health_warning
  end

  def given_a_taxon
    @taxon_content_id = SecureRandom.uuid
    @taxon = taxon_with_details(
      "Taxon 1",
      other_fields: { content_id: @taxon_content_id }
    )

    stub_requests_for_show_page(@taxon)
  end

  def given_a_health_warning
    Taxonomy::HealthWarning.create(content_id: @taxon_content_id,
                                   title: 'title',
                                   internal_name: 'internal name',
                                   path: '/path/to/taxon',
                                   metric: 'TaxonomyHealth::ContentCountMetric',
                                   message: 'Taxon fails metric')
  end

  def when_i_visit_the_health_warnings_page
    visit taxonomy_health_warnings_path
  end

  def then_i_see_the_health_warning
    expect(page).to have_text('/path/to/taxon')
    expect(page).to have_text('Taxon fails metric')
    expect(page).to have_link('internal name', href: taxon_path(@taxon_content_id))
  end

  def then_i_see_a_link_to_the_metrics_dashboard
    Plek.new.stubs(:external_url_for).with('grafana').returns('http://grafana')

    expect(page).to have_link('View taxonomy metrics dashboard', href: 'http://grafana')
  end
end
