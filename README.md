# Content Tagger

App for tagging content on GOV.UK.

## Nomenclature

- **Word**: definition of word, and how it's used in the code

## Technical documentation

This is a Ruby on Rails application that works with the publishing-api to manage
the "links hash" for content on GOV.UK.

### Dependencies

- [alphagov/content-store](https://github.com/alphagov/content-store) - provides access to content on GOV.UK
- [alphagov/publishing-api](https://github.com/alphagov/publishing-api) - used to publish links

### Running the application

`./startup.sh`

Documentation for where the app will appear (default port, vhost, URL etc).

### Running the test suite

`bundle exec rake`

Include any other edge cases, e.g parallel test runner in Whitehall

### Any deviations from idiomatic Rails/Go etc. (optional)

### Example API output (optional)

`one-line-curl-command with JSON response after`

Keep this section limited to core endpoints - if the app is complex link out to `/docs`.

## Licence

[MIT License](LICENCE)
