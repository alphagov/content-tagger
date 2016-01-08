module AlphaTaxonomy
  module SharedExceptions
    class MissingImportFileError < StandardError
      def message
        "Run AlphaTaxonomy::ImportFile#populate to create import file"
      end
    end
  end
end
