class LookupController < ApplicationController
  def new
    @lookup = ContentLookupForm.new
  end

  def find_by_slug
    content_lookup = ContentLookupForm.new(params[:content_lookup_form])

    if content_lookup.valid?
      redirect_to content_path(content_lookup.content_id)
    else
      @lookup = content_lookup
      render 'new'
    end
  end
end
