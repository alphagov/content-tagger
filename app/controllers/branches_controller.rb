class BranchesController < ApplicationController
  before_action :ensure_user_can_use_application!
  before_action :ensure_user_can_administer_taxonomy!, only: %i[edit_all update_all]

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
end
