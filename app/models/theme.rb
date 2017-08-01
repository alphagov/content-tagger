class Theme < ActiveRecord::Base
  def self.taxon_path_prefixes
    pluck(:path_prefix)
  end

  def self.prefix_to_name(prefix)
    where(path_prefix: prefix).pluck(:name).first
  end
end
