# rubocop:disable Metrics/ClassLength
class TaxonsController < ApplicationController
  VISUALISATIONS = %w[list bubbles taxonomy_tree].freeze

  before_action(
    :ensure_user_can_administer_taxonomy!,
    except: %i[index drafts trash show visualisation_data tagged_content download]
  )

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
      Taxonomy::UpdateTaxon.call(taxon: taxon, version_note: params[:internal_change_note])
      redirect_to taxon_path(taxon.content_id), success: t('controllers.taxons.create_success')
    else
      error_messages = taxon.errors.full_messages.join('; ')
      flash.now[:danger] = error_messages
      render :new, locals: { page: Taxonomy::EditPage.new(taxon) }
    end
  rescue Taxonomy::UpdateTaxon::InvalidTaxonError => e
    flash.now[:danger] = e.message
    render :new, locals: { page: Taxonomy::EditPage.new(taxon) }
  end

  def show
    respond_to do |format|
      format.html do
        render locals: {
          page: Taxonomy::ShowPage.new(taxon, params.fetch(:viz, 'taxonomy_tree'))
        }
      end

      format.json { render json: taxon }
    end
  rescue Taxonomy::BuildTaxon::TaxonNotFoundError
    render "taxon_not_found", status: 404
  end

  def visualisation_data
    render json: Taxonomy::TaxonsWithContentCount.new(taxon).nested_tree
  end

  def tagged_content
    render :tagged_content_page, locals: { page: Taxonomy::TaggedContentPage.new(taxon) }
  end

  def history
    render :history, locals: { page: Taxonomy::TaxonHistoryPage.new(taxon) }
  end

  def edit
    render :edit, locals: { page: Taxonomy::EditPage.new(taxon) }
  end

  def update
    taxon = Taxon.new taxon_params

    if taxon.valid?
      Taxonomy::UpdateTaxon.call(taxon: taxon, version_note: params[:internal_change_note])

      if params[:publish_taxon_on_save] == "true"
        Services.publishing_api.publish(taxon.content_id)
      end

      redirect_to taxon_path(taxon.content_id)
    else
      error_messages = taxon.errors.full_messages.join('; ')
      flash.now[:danger] = error_messages
      render :edit, locals: { page: Taxonomy::EditPage.new(taxon) }
    end
  rescue Taxonomy::UpdateTaxon::InvalidTaxonError => e
    flash.now[:danger] = e.message
    render :edit, locals: { page: Taxonomy::EditPage.new(taxon) }
  end

  def destroy
    if content_id == GovukTaxonomy::ROOT_CONTENT_ID
      redirect_to taxon_path(content_id), danger: t("controllers.taxons.destroy_homepage")
    elsif params[:taxon][:redirect_to].empty?
      flash.now[:danger] = t("controllers.taxons.destroy_no_redirect")
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
    Taxonomy::UpdateTaxon.call(taxon: taxon, version_note: 'Restore')
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

  def confirm_bulk_publish
    render :confirm_bulk_publish, locals: { page: Taxonomy::ShowPage.new(taxon) }
  end

  def bulk_publish
    Taxonomy::BulkUpdateTaxon.call(content_id)
    redirect_to taxon_path(content_id), success: "The taxons will be published shortly"
  end

  def publish
    Services.publishing_api.publish(content_id)
    redirect_to taxon_path(content_id), success: "You have successfully published the taxon"
  rescue GdsApi::HTTPUnprocessableEntity => e
    # Perform a lookup on the base path to determine whether there
    # is already another content item published with the same path

    existing_content_id = Services.publishing_api.lookup_content_id(
      base_path: taxon.base_path
    )

    if existing_content_id.present?
      flash.now[:danger] = ActionController::Base.helpers.sanitize(
        I18n.t('errors.invalid_taxon_base_path', taxon_path: taxon_path(existing_content_id))
      )
    else
      GovukError.notify(e, level: "warning")
      flash.now[:danger] = I18n.t('errors.invalid_taxon')
    end

    render :edit, locals: { page: Taxonomy::EditPage.new(taxon) }
  end

  def confirm_discard
    render :confirm_discard, locals: { taxon: taxon }
  end

  def discard_draft
    Services.publishing_api.discard_draft(content_id)
    redirect_to taxons_path, success: t("controllers.taxons.discard_draft_success")
  end

  def download
    export = Taxonomy::TaxonsExport.new
    send_data export.to_csv, filename: "#{Date.today} Taxonomy.csv"
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
      :path_slug,
      :internal_name,
      :title,
      :description,
      :visible_to_departmental_editors,
      :phase,
      :notes_for_editors,
      :parent,
      associated_taxons: [],
    ).merge(parent_path_prefix)
  end

  def parent_path_prefix
    return if params[:taxon][:parent].blank?
    parent_taxon = Taxonomy::BuildTaxon.call(content_id: params[:taxon][:parent])
    {
      path_prefix: parent_taxon.path_prefix
    }
  end

  def content_id
    params[:id] || params[:taxon_id]
  end

  def taxon
    @_taxon ||= Taxonomy::BuildTaxon.call(content_id: content_id)
  end

  helper_method :visualisation_to_render
end
