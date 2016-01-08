module AlphaTaxonomy
  module Helpers
    module ImportFileHelper
      def check_import_file_is_present
        raise AlphaTaxonomy::SharedExceptions::MissingImportFileError unless File.exist? AlphaTaxonomy::ImportFile.location
      end
    end
  end
end
