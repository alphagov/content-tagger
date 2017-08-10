class ProjectsController < ApplicationController
  def index
    render :index, locals: { projects: project_index }
  end

  def show
    render :show, locals: { project: project,
                            project_content_items_to_display: project_content_items_to_display }
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

  def project_index
    @_project_index = Project.all
  end

  def project
    @_project ||= Project.find(params[:id])
  end

  def project_content_items_to_display
    @_project_content_items_to_display = begin
      items = project.content_items.uncompleted
      items = items.matching_search(search_query) if search_query

      items
    end
  end

  def new_project_params
    params
      .fetch(:new_project_form)
      .permit(:name, :remote_url, :taxonomy_branch)
  end

  def search_query
    params[:query]
  end
end
