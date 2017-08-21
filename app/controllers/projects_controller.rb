class ProjectsController < ApplicationController
  def index
    render :index, locals: { projects: project_index }
  end

  def show
    render :show, locals: { project: project,
                            bulk_search: Projects::BulkSearch.new(project, params),
                            taxons: taxons_json }
  end

  def new
    render :new, locals: { form: NewProjectForm.new }
  end

  def create
    form = NewProjectForm.new(new_project_params)
    if form.valid? && form.create
      redirect_to projects_path
    else
      render :new, locals: { form: form }
    end
  end

private

  def taxons_json
    project
      .taxons
      .reduce({}) { |acc, taxon| acc.merge(taxon.content_id => taxon.name) }
      .to_json
  end

  def project_index
    @_project_index = Project.all
  end

  def project
    @_project ||= Project.find(params[:id])
  end

  def new_project_params
    params
      .fetch(:new_project_form)
      .permit(:name, :remote_url, :taxonomy_branch)
  end
end
