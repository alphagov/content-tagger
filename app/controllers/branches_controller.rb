class BranchesController < ApplicationController
  VISUALISATIONS = %w[list bubbles].freeze

  before_action :ensure_user_can_use_application!
  before_action :ensure_user_can_administer_taxonomy!, only: %i[edit_all update_all]

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
    render :edit_all, locals: { form: BranchesForm.new }
  end

  def update_all
    BranchesForm.new(branches_params).update
    redirect_to edit_all_branches_path
  end

private

  def branches_params
    params.require(:branches_form).permit(branches: [])
  end

  def visualisation_to_render
    params.fetch(:viz, "bubbles")
  end

  helper_method :visualisation_to_render
end
