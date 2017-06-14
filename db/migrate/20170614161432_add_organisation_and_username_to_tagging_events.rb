class AddOrganisationAndUsernameToTaggingEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :tagging_events, :user_name, :string
    add_column :tagging_events, :user_organisation, :string
  end
end
