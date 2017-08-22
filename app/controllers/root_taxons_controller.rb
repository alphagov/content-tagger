class RootTaxonsController < ApplicationController
  before_action :ensure_user_can_administer_taxonomy!

  def index
    render :index, locals: { page: RootTaxonsForm.new }
  end

  def update
    RootTaxonsForm.new(root_taxons_params).update
    redirect_to taxons_path
  end

private

  def root_taxons_params
    params.require(:root_taxons_form).permit(root_taxons: [])
  end
end
