task import_tagging_events: [:environment] do
  TaggingEvent.delete_all
  CSV.foreach(ENV['FILENAME'], headers: true) do |row|
    TaggingEvent.create!(row.to_h)
  end
end
