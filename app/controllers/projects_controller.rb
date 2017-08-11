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
      items = project.content_items

      tagged_state_filter = filter_params[:tagged_state]
      if tagged_state_filter && tagged_state_filter != "all"
        done = { tagged: true, not_tagged: false }[tagged_state_filter.to_sym]

        if done.nil?
          raise ActionController::BadRequest,
                "The value \"#{tagged_state_filter}\" is an invalid tagging state."
        end

        items = items.where(done: done)
      end

      query = filter_params[:query]
      items = items.matching_search(query) if query

      items
    end
  end

  def new_project_params
    params
      .fetch(:new_project_form)
      .permit(:name, :remote_url, :taxonomy_branch)
  end

  def filter_params
    params.permit(:query, :tagged_state)
  end
end
