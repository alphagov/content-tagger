class ProjectsController < ApplicationController
  before_action :ensure_user_can_access_tagathon_tools!
  before_action :ensure_user_can_administer_taxonomy!, only: %i[confirm_delete destroy]

  def index
    render :index, locals: {
      percentage_by_organisation: tagging_progress_query.try(:percentage_tagged),
      total_counts: tagging_progress_query.try(:total_counts),
      projects: project_index
    }
  end

  def show
    query = ProjectFilterQuery.new(params, project)
    render :show, locals: { content_items: Projects::PrepareContentItems.call(query.items),
                            filters: ProjectFilterQuery::FILTERS,
                            project: project,
                            taxons: taxons,
                            query: query }
  end

  def new
    render :new, locals: { form: NewProjectForm.new }
  end

  def create
    form = NewProjectForm.new(new_project_params)
    if form.create
      redirect_to projects_path
    else
      render :new, locals: { form: form }
    end
  end

  def confirm_delete
    render :confirm_delete, locals: { project: project }
  end

  def destroy
    project.destroy!
    redirect_to projects_path, success: 'You have successfully deleted the project'
  end

private

  def taxons
    project
      .taxons
      .reduce({}) do |acc, taxon|
        acc.merge(
          taxon.content_id => {
            name: taxon.name,
            parent_id: taxon.parent_node.try(:content_id)
          }
        )
      end
  end

  def project_index
    @project_index = Project.all.order(:taxonomy_branch, :name)
  end

  def project
    @project ||= Project.find(project_id)
  end

  def project_id
    params[:id] || params[:project_id]
  end

  def new_project_params
    params
      .fetch(:new_project_form)
      .permit(:name, :remote_url, :taxonomy_branch, :bulk_tagging_enabled)
  end

  def tagging_progress_query
    return if params[:progress_for_organisations].blank?

    organisations = params[:progress_for_organisations].tr(' ', '').split(',')
    @tagging_progress_query ||= TaggingProgressByOrganisationsQuery.new(organisations)
  end
end
