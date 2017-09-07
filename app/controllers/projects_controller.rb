class ProjectsController < ApplicationController
  before_action :ensure_user_can_access_tagathon_tools!

  def index
    render :index, locals: { projects: project_index }
  end

  def show
    render :show, locals: { project: project,
                            bulk_search: searcher,
                            taxons: taxons,
                            content_items: content_items }
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

  def searcher
    @_search ||= Projects::BulkSearch.new(project, params)
  end

  def content_items
    @_content_items ||= Projects::PrepareContentItems.call(searcher.project_content_items_to_display)
  end

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
    @_project_index = Project.all
  end

  def project
    @_project ||= Project.find(params[:id])
  end

  def new_project_params
    params
      .fetch(:new_project_form)
      .permit(:name, :remote_url, :taxonomy_branch, :bulk_tagging_enabled)
  end
end
