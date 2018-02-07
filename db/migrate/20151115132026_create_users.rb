class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :uid
      t.string :organisation_slug
      t.string :organisation_content_id
      t.text :permissions
      t.boolean :remotely_signed_out
      t.boolean :disabled

      t.timestamps null: false
    end
  end
end
