class NewProjectForm
  include ActiveModel::Model

  attr_accessor :name, :remote_url

  validates_presence_of :name, :remote_url
  validates :remote_url, format: URI.regexp(%w(http https))

  def create
    csv = RemoteCsv.new(remote_url)
    ProjectBuilder.call(name, csv.to_enum)
  rescue URI::InvalidURIError,
         ActiveRecord::RecordInvalid,
         Errno::ECONNREFUSED,
         CSV::MalformedCSVError,
         ActiveModel::UnknownAttributeError,
         SocketError => ex
    errors[:remote_url] << ex.message
    false
  end
end
