class TaxonsController < ApplicationController
  def index
    search_results = remote_taxons.search(
      page: params[:page],
      per_page: params[:per_page],
      query: query
    )

    render :index, locals: {
      taxons: search_results.taxons,
      search_results: search_results,
      query: query,
    }
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
      Taxonomy::PublishTaxon.call(taxon: new_taxon)
      redirect_to(taxons_path)
    else
      error_messages = new_taxon.errors.full_messages.join('; ')
      locals = {
        taxon: new_taxon,
        taxons_for_select: taxons_for_select
      }
      render :new, locals: locals, flash: { error: error_messages }
    end
  rescue Taxonomy::PublishTaxon::InvalidTaxonError => e
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
    Taxonomy::PublishTaxon.call(taxon: new_taxon)
    redirect_to taxons_path
  end

  def destroy
    response_code = Services.publishing_api.unpublish(params[:id], type: "gone").code

    redirect_to taxons_path, flash: destroy_flash_message(response_code)
  end

private

  def destroy_flash_message(response_code)
    if response_code == 200
      { success: I18n.t('controllers.taxons.success') }
    else
      { alert: I18n.t('controllers.taxons.alert') }
    end
  end

  def taxons_for_select
    Linkables.new.taxons
  end

  def parent_taxons
    remote_taxons.parents_for_taxon(taxon)
  end

  def remote_taxons
    @remote_taxons ||= RemoteTaxons.new
  end

  def taxon
    Taxonomy::BuildTaxon.call(content_id: params[:id])
  end

  def tagged
    Services.publishing_api.get_linked_items(
      taxon.content_id,
      link_type: "taxons",
      fields: %w(title content_id base_path document_type)
    )
  end

  def query
    return '' unless params[:taxon_search].present?

    params[:taxon_search][:query]
  end
end
