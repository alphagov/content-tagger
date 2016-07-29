class TaxonsController < ApplicationController
  def index
    render :index, locals: { taxons: taxon_fetcher.taxons }
  end

  def new
    render :new, locals: {
      taxon_form: TaxonForm.new,
      taxons_for_select: taxons_for_select,
    }
  end

  def create
    new_taxon = TaxonForm.new(params[:taxon_form])
    if new_taxon.valid?
      Taxonomy::Publisher.publish(taxon_form: new_taxon)
      redirect_to taxons_path
    else
      error_messages = new_taxon.errors.full_messages.join('; ')
      redirect_to new_taxon_path, flash: { error: error_messages }
    end
  rescue Taxonomy::Publisher::InvalidTaxonError => e
    redirect_to new_taxon_path, flash: { error: e.message }
  end

  def show
    render :show, locals: {
      taxon_form: taxon_form,
      tagged: tagged,
      parent_taxons: parent_taxons,
    }
  end

  def edit
    render :edit, locals: {
      taxon_form: taxon_form,
      taxons_for_select: taxons_for_select,
    }
  end

  def update
    new_taxon = TaxonForm.new(params[:taxon_form])
    Taxonomy::Publisher.publish(taxon_form: new_taxon)
    redirect_to taxons_path
  end

private

  def taxons_for_select
    taxon_fetcher.taxons_for_select
  end

  def parent_taxons
    taxon_fetcher.parents_for_taxon_form(taxon_form)
  end

  def taxon_fetcher
    @taxon_fetcher ||= Taxonomy::TaxonFetcher.new
  end

  def taxon_form
    Taxonomy::TaxonFormBuilder.build(content_id: params[:id])
  end

  def tagged
    Services.publishing_api.get_linked_items(
      taxon_form.content_id,
      link_type: "taxons",
      fields: %w(title content_id base_path)
    )
  end
end
