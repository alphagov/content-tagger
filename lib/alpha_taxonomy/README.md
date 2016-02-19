# Alpha Taxonomy Bulk Import

The set of files in this folder provide functionality to get alpha-stage
taxonomy data into the content store via a bulk import. Broadly, this involves:

- downloading, parsing, and compiling a set of mapping spreadsheets into a
  single TSV (tab-separated values) import file.
- using the import file to create individual taxons in the content store.
- updating the links hash of mapped content items to their respective taxons.

## Running the import

Importing a new set of taxon data involves the following:

0. Put a taxonomy spreadsheet on Google Drive with the following fields. It
might have more fields than this on the sheet, but it must have the fields
below in order for the import to work. Also, note the pipe-seperated list of
taxons in `mapped to`.
  ```
  +-------------------+-----------------+
  |     mapped to     |      link       |
  +-------------------+-----------------+
  | taxon 1 | taxon 2 | /some/base/path |
  +-------------------+-----------------+
  ```

0. Make the sheet public on Google Drive in TSV format. Its public URL should
   look something like this:
   `https://docs.google.com/spreadsheets/d/19GhkAQ9VEmsiPeoHbrz9Q-nTnbtLxC2kkD6szoGGam0/edit#gid=1102496302`.
   The `19Ghka...` part is the `key` and the param at the end is the `gid`.
0. In the environment in which you're running the import, set an environment
   variable `TAXON_SHEETS` with values in the form
   `name-of-sheet,the-key,the-gid,name-of-some-other-sheet,its-key,its-gid`.
   You can set as many sets of credentials as you need as long as the values
   are comma-delimited and provided in this order.
0. Run `AlphaTaxonomy::ImportFile.new.populate`.
0. This should pull down each sheet defined in the environment variable and
   write the contents into a single import file. A default location for the
   import file is specified in the class, however this can be overidden by
   setting the environment variable `TAXON_IMPORT_FILE` to a target filename.
0. Run `AlphaTaxonomy::TaxonCreator.new.run!`.
0. This will refer to the import file and create any new taxons that it finds
   in there. It converts each taxon title into its base_path form when checking
   if the taxon already exists, so should gracefully handle duplicate taxon
   titles with subtly different capitalisation/punctuation - as long as the
   base path looks the same.
0. Run `TaxonLinker` to establish mappings between content and taxons.
0. This updates the links hash of content items specified in the import file.

## Improvements

* The bulk importer does not currently have a mechanism to establish
  hierarchical relationship between taxons en masse. At time of writing this is
  handled completely manually in
  [content-tagger](https://github.com/alphagov/content-tagger).
