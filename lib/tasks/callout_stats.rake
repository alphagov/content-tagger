require "gds_api/base"
require "digest"

desc "Get stats regarding callouts"
task callout_statistics: :environment do
  callouts = []
  links = Services.search_api.search_enum({ fields: "link" }, page_size: 1000).lazy.map { |z| z["link"] }.to_a
  links.each_with_index do |link, index|
    begin
      if (index % 100).zero?
        puts "Processed documents: #{index}"
        puts "Number of callouts found #{callouts.count} "
        puts "Number of unique callouts found #{callouts.map { |c| c[:body] }.uniq.count} "
      end
      content_item = begin
        Services.live_content_store.content_item(link).to_h
                     rescue GdsApi::HTTPGatewayTimeout, GdsApi::TimedOutException, GdsApi::HTTPBadGateway
                       retries ||= 0
                       raise if retries >= 3

                       retries += 1
                       sleep 2
                       retry
      end
      bodies = (content_item.dig("details", "parts") || []).map { |p| p.fetch("body", "") }
      body = content_item.dig("details", "body")
      bodies << body unless body.nil?
      results = bodies.map { |b| Nokogiri.HTML(b).css(".call-to-action") }.flat_map(&:to_s).compact
      results.each do |result|
        callouts << { body: result, publishing_app: content_item["publishing_app"], md5: Digest::MD5.hexdigest(result) } unless result.empty?
      end
    rescue StandardError
      puts "Skipping..."
    end
  end

  groups = callouts.group_by { |co| co[:md5] }.values
  groups.reject! { |group| group.count == 1 }
  output_file = File.open("/tmp/output.csv", "w+")
  CSV(output_file, write_headers: false) do |csv|
    groups.each do |group|
      apps_data = group.group_by { |value| value[:publishing_app] }.values.map { |v| { publishing_app: v.first[:publishing_app], count: v.count } }
      row = [group.first[:body], group.count]
      apps_data.each do |d|
        row << d[:publishing_app]
        row << d[:count]
      end
      csv << row
    end
  end
  output_file.flush
  output_file.rewind
  IO.copy_stream(output_file, $stdout)
  output_file.close
end
