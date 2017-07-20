module LegacyTaxonomy
  class Yamlizer
    def initialize(filename)
      @filename = filename
    end

    def read
      # The psych YAML parser doesn't work with the Rails class autoloader.
      # And while there are more complicated ways of fixing this...
      _ = LegacyTaxonomy::TaxonData
      YAML.load_file(@filename)
    end

    def write(taxonomy)
      File.write(@filename, YAML.dump(taxonomy))
    end
  end
end
