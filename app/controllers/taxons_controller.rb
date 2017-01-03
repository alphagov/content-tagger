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
    taxon = Taxon.new(params[:taxon])

    if taxon.valid?
      Taxonomy::PublishTaxon.call(taxon: taxon)
      redirect_to(taxons_path)
    else
      error_messages = taxon.errors.full_messages.join('; ')
      locals = { taxon: taxon, taxons_for_select: taxons_for_select }
      render :new, locals: locals, flash: { error: error_messages }
    end
  rescue Taxonomy::PublishTaxon::InvalidTaxonError => e
    redirect_to(new_taxon_path, flash: { error: e.message })
  end

  def show
    taxonomy_tree = Taxonomy::ExpandedTaxonomy.new(taxon.content_id).build
    render :show, locals: {
      taxon: taxon,
      tagged: tagged,
      taxonomy_tree: taxonomy_tree,
    }
  rescue Taxonomy::BuildTaxon::TaxonNotFoundError
    render "taxon_not_found", status: 404
  end

  def edit
    render :edit, locals: {
      taxon: taxon,
      taxons_for_select: taxons_for_select(exclude_ids: taxon.content_id),
    }
  end

  def update
    taxon = Taxon.new(params[:taxon])

    if taxon.valid?
      Taxonomy::PublishTaxon.call(taxon: taxon)
      redirect_to(taxons_path)
    else
      error_messages = taxon.errors.full_messages.join('; ')
      locals = { taxon: taxon, taxons_for_select: taxons_for_select(exclude_ids: taxon.content_id) }
      render :edit, locals: locals, flash: { error: error_messages }
    end
  rescue Taxonomy::PublishTaxon::InvalidTaxonError => e
    redirect_to edit_taxon_path(new_taxon.content_id), flash: { error: e.message }
  end

  def destroy
    response_code = Services.publishing_api.unpublish(params[:id], type: "gone").code
    redirect_to taxons_path, flash: destroy_flash_message(response_code)
  end

  def confirm_delete
    expanded_taxonomy = Taxonomy::ExpandedTaxonomy.new(taxon.content_id).build

    render :confirm_delete, locals: {
      taxon: taxon,
      tagged: tagged,
      children: expanded_taxonomy.child_expansion.children,
    }
  end

private

  def destroy_flash_message(response_code)
    if response_code == 200
      { success: I18n.t('controllers.taxons.success') }
    else
      { alert: I18n.t('controllers.taxons.alert') }
    end
  end

  def taxons_for_select(exclude_ids: nil)
    Linkables.new.taxons(exclude_ids: exclude_ids)
  end

  def remote_taxons
    @remote_taxons ||= RemoteTaxons.new
  end

  def taxon
    content_id = params[:id] || params[:taxon_id]
    Taxonomy::BuildTaxon.call(content_id: content_id)
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
