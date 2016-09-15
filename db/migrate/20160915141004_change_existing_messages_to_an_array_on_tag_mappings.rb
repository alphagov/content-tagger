class ChangeExistingMessagesToAnArrayOnTagMappings < ActiveRecord::Migration
  def change
    TagMapping.transaction do
      TagMapping.all.each do |tag_mapping|
        current_messages = tag_mapping.messages
        # We have stored messages in the database as strings separated by ".". The
        # reason we are not splitting existing messages by "." here is because we
        # have strings like "GOV.UK", which would incorrectly be split. This will
        # allow us to serialize all the existing messages as an array.
        tag_mapping.messages = [current_messages]
        tag_mapping.save!
      end
    end
  end
end
