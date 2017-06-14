task import_tagging_events: [:environment] do
  TaggingEvent.delete_all
  CSV.foreach(ENV['FILENAME'], headers: true) do |row|
    TaggingEvent.create!(row.to_h)
  end
end

task augment_with_users: [:environment] do
  users = JSON.parse(File.read(ENV['FILENAME']))
  users.each do |user|
    TaggingEvent.where(
      user_uid: user["user_uid"]
    ).update_all(
      user_name: user["name"],
      user_organisation: user["organisation"],
    )
  end
end
