class RootTaxonsController < ApplicationController
  VISUALISATIONS = %w(list bubbles).freeze

  before_action :ensure_user_can_administer_taxonomy!

  def show
    @content_item = ContentItem.find!(params[:id])

    @taxonomy_size = Taxonomy::TaxonomySizePresenter.new(
      Taxonomy::TaxonomySize.new(@content_item)
    )

    respond_to do |format|
      format.html
      format.json do
        render json: @taxonomy_size.nested_tree
      end
    end
  end

  def edit_all
    render :edit_all, locals: { form: RootTaxonsForm.new }
  end

  def update_all
    RootTaxonsForm.new(root_taxons_params).update
    redirect_to edit_all_root_taxons_path
  end

private

  def root_taxons_params
    params.require(:root_taxons_form).permit(root_taxons: [])
  end

  def visualisation_to_render
    params.fetch(:viz, "bubbles")
  end

  helper_method :visualisation_to_render
end
