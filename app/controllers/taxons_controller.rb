class TaxonsController < ApplicationController
  def index
    render_index_for_taxons_in_state("published")
  end

  def drafts
    render_index_for_taxons_in_state("draft")
  end

  def trash
    render_index_for_taxons_in_state("unpublished")
  end

  def new
    render :new, locals: {
      taxon: Taxon.new,
      taxons_for_select: taxons_for_select,
      path_prefixes_for_select: path_prefixes_for_select,
    }
  end

  def create
    taxon = Taxon.new(params[:taxon])

    locals = {
      taxon: taxon,
      taxons_for_select: taxons_for_select,
      path_prefixes_for_select: path_prefixes_for_select,
    }

    if taxon.valid?
      Taxonomy::PublishTaxon.call(taxon: taxon)
      redirect_to taxon_path(taxon.content_id), success: t('controllers.taxons.create_success')
    else
      error_messages = taxon.errors.full_messages.join('; ')
      flash[:danger] = error_messages
      render :new, locals: locals
    end
  rescue Taxonomy::PublishTaxon::InvalidTaxonError => e
    flash[:danger] = e.message
    render :new, locals: locals
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
      path_prefixes_for_select: path_prefixes_for_select,
    }
  end

  def update
    taxon = Taxon.new(params[:taxon])

    locals = {
      taxon: taxon,
      taxons_for_select: taxons_for_select(exclude_ids: taxon.content_id),
      path_prefixes_for_select: path_prefixes_for_select,
    }

    if taxon.valid?
      Taxonomy::PublishTaxon.call(taxon: taxon)
      redirect_to(taxons_path)
    else
      error_messages = taxon.errors.full_messages.join('; ')
      flash[:danger] = error_messages
      render :edit, locals: locals
    end
  rescue Taxonomy::PublishTaxon::InvalidTaxonError => e
    flash[:danger] = e.message
    render :edit, locals: locals
  end

  def destroy
    response_code = Services.publishing_api.unpublish(params[:id], type: "gone").code

    flash_message = if response_code == 200
                      { success: I18n.t("controllers.taxons.destroy_success") }
                    else
                      { alert: I18n.t("controllers.taxons.destroy_alert") }
                    end

    redirect_to taxon_path(taxon.content_id), flash: flash_message
  end

  def confirm_delete
    expanded_taxonomy = Taxonomy::ExpandedTaxonomy.new(taxon.content_id).build

    render :confirm_delete, locals: {
      taxon: taxon,
      tagged: tagged,
      children: expanded_taxonomy.child_expansion.children,
    }
  end

  def restore
    Taxonomy::PublishTaxon.call(taxon: taxon)

    flash_message = if response_code == 200
                      { success: I18n.t("controllers.taxons.restore_success") }
                    else
                      { alert: I18n.t("controllers.taxons.restore_alert") }
                    end

    redirect_to taxon_path(taxon.content_id), flash: flash_message
  rescue Taxonomy::PublishTaxon::InvalidTaxonError => e
    redirect_to trash_taxons_path, flash: { danger: e.message }
  end

  def confirm_publish
    render :confirm_publish, locals: { taxon: taxon }
  end

  def publish
    Services.publishing_api.publish(taxon.content_id, "major")
    redirect_to taxon_path(taxon.content_id), success: "You have successfully published the taxon"
  end

private

  def render_index_for_taxons_in_state(state)
    search_results = remote_taxons.search(
      page: params[:page],
      per_page: params[:per_page],
      query: query,
      states: [state]
    )

    render :index, locals: {
      taxons: search_results.taxons,
      search_results: search_results,
      query: query,
    }
  end

  def path_prefixes_for_select
    Theme.taxon_path_prefixes
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
    return [] if taxon.unpublished?

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
