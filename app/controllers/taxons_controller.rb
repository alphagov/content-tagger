class TaxonsController < ApplicationController
  def index
    render :index, locals: { taxons: taxon_fetcher.taxons }
  end

  def new
    render :new, locals: {
      taxon: Taxon.new,
      taxons_for_select: taxons_for_select,
    }
  end

  def create
    new_taxon = Taxon.new(params[:taxon])
    if new_taxon.valid?
      Taxonomy::Publisher.publish(taxon: new_taxon)
      redirect_to(taxons_path)
    else
      error_messages = new_taxon.errors.full_messages.join('; ')
      locals = {
        taxon: new_taxon,
        taxons_for_select: taxons_for_select
      }
      render :new, locals: locals, flash: { error: error_messages }
    end
  rescue Taxonomy::Publisher::InvalidTaxonError => e
    redirect_to(new_taxon_path, flash: { error: e.message })
  end

  def show
    render :show, locals: {
      taxon: taxon,
      tagged: tagged,
      parent_taxons: parent_taxons,
    }
  end

  def edit
    render :edit, locals: {
      taxon: taxon,
      taxons_for_select: taxons_for_select,
    }
  end

  def update
    new_taxon = Taxon.new(params[:taxon])
    Taxonomy::Publisher.publish(taxon: new_taxon)
    redirect_to taxons_path
  end

private

  def taxons_for_select
    taxon_fetcher.taxons_for_select
  end

  def parent_taxons
    taxon_fetcher.parents_for_taxon(taxon)
  end

  def taxon_fetcher
    @taxon_fetcher ||= Taxonomy::TaxonFetcher.new
  end

  def taxon
    Taxonomy::TaxonBuilder.build(content_id: params[:id])
  end

  def tagged
    Services.publishing_api.get_linked_items(
      taxon.content_id,
      link_type: "taxons",
      fields: %w(title content_id base_path)
    )
  end
end
