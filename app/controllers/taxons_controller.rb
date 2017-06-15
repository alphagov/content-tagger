class TaxonsController < ApplicationController
  def index
    render :index, locals: { page: Taxonomy::IndexPage.new(params, "published") }
  end

  def drafts
    render :index, locals: { page: Taxonomy::IndexPage.new(params, "draft") }
  end

  def trash
    render :index, locals: { page: Taxonomy::IndexPage.new(params, "unpublished") }
  end

  def new
    render :new, locals: { page: Taxonomy::EditPage.new(Taxon.new) }
  end

  def create
    taxon = Taxon.new taxon_params

    if taxon.valid?
      Taxonomy::UpdateTaxon.call(taxon: taxon)
      redirect_to taxon_path(taxon.content_id), success: t('controllers.taxons.create_success')
    else
      error_messages = taxon.errors.full_messages.join('; ')
      flash[:danger] = error_messages
      render :new, locals: { page: Taxonomy::EditPage.new(taxon) }
    end
  rescue Taxonomy::UpdateTaxon::InvalidTaxonError => e
    flash[:danger] = e.message
    render :new, locals: { page: Taxonomy::EditPage.new(taxon) }
  end

  def show
    render :show, locals: { page: Taxonomy::ShowPage.new(taxon) }
  rescue Taxonomy::BuildTaxon::TaxonNotFoundError
    render "taxon_not_found", status: 404
  end

  def edit
    render :edit, locals: { page: Taxonomy::EditPage.new(taxon) }
  end

  def update
    taxon = Taxon.new taxon_params

    if taxon.valid?
      Taxonomy::UpdateTaxon.call(taxon: taxon)

      if params[:publish_taxon_on_save] == "true"
        Services.publishing_api.publish(taxon.content_id, "major")
      end

      redirect_to taxon_path(taxon.content_id)
    else
      error_messages = taxon.errors.full_messages.join('; ')
      flash[:danger] = error_messages
      render :edit, locals: { page: Taxonomy::EditPage.new(taxon) }
    end
  rescue Taxonomy::UpdateTaxon::InvalidTaxonError => e
    flash[:danger] = e.message
    render :edit, locals: { page: Taxonomy::EditPage.new(taxon) }
  end

  def destroy
    if params[:taxon][:redirect_to].empty?
      flash[:danger] = t("controllers.taxons.destroy_no_redirect")
      render :confirm_delete, locals: { page: Taxonomy::ShowPage.new(taxon) }
    else
      base_path = Services.publishing_api.get_content(params[:taxon][:redirect_to])['base_path']
      Services.publishing_api.unpublish(params[:id], type: "redirect", alternative_path: base_path)
      redirect_to taxon_path(taxon.content_id), success: t("controllers.taxons.destroy_success")
    end
  end

  def confirm_delete
    render :confirm_delete, locals: { page: Taxonomy::ShowPage.new(taxon) }
  end

  def restore
    Taxonomy::UpdateTaxon.call(taxon: taxon)
    redirect_to taxon_path(taxon.content_id), success: t("controllers.taxons.restore_success")
  rescue Taxonomy::UpdateTaxon::InvalidTaxonError => e
    redirect_to trash_taxons_path, danger: e.message
  end

  def confirm_restore
    render :confirm_restore, locals: { page: Taxonomy::ShowPage.new(taxon) }
  end

  def confirm_publish
    render :confirm_publish, locals: { taxon: taxon }
  end

  def publish
    Services.publishing_api.publish(taxon.content_id, "major")
    redirect_to taxon_path(taxon.content_id), success: "You have successfully published the taxon"
  end

  def confirm_discard
    render :confirm_discard, locals: { taxon: taxon }
  end

  def discard_draft
    Services.publishing_api.discard_draft(taxon.content_id)
    redirect_to taxons_path, success: t("controllers.taxons.discard_draft_success")
  end

  def download_tagged
    export = Taxonomy::TaxonomyExport.new(taxon.content_id)
    send_data export.to_csv,
              filename: "#{Date.today} content tagged to #{taxon.title}.csv"
  end

private

  def taxon_params
    params.require(:taxon).permit(
      :content_id,
      :path_prefix,
      :path_slug,
      :internal_name,
      :title,
      :description,
      :visible_to_departmental_editors,
      :notes_for_editors,
      :parent,
      associated_taxons: [],
    )
  end

  def taxon
    @_taxon ||= begin
      content_id = params[:id] || params[:taxon_id]
      Taxonomy::BuildTaxon.call(content_id: content_id)
    end
  end
end
