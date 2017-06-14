class AddOrganisationAndUsernameToTaggingEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :tagging_events, :user_name, :string
    add_column :tagging_events, :user_organisation, :string

    add_index :tagging_events, :user_name
    add_index :tagging_events, :user_organisation
  end
end
