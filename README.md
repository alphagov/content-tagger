# Content Tagger

Its main purpose is to provide an interface that allows content to be tagged and bulk-tagged.
It also provides an interface for adding and updating taxons.

## Technical documentation

This is a Ruby on Rails application.
It interacts with the publishing-api to manage the "links hash" for content on GOV.UK.
It also allows the creation of new taxons, updating taxons and bulk-tagging.

## Screenshots

![Homepage](docs/screenshot-homepage.png)
![Tagging Interface](docs/screenshot-edit-tagging.png)
![Taxons](docs/screenshot-taxons.png)
![View Taxon](docs/screenshot-taxon.png)
![Edit Taxon](docs/screenshot-edit-taxon.png)

### Dependencies

- [alphagov/publishing-api](https://github.com/alphagov/publishing-api) - used to publish links

### Running the application

```
$ bowl content-tagger
```

If you're using the VM, the app should appear on [http://content-tagger.dev.gov.uk/](http://content-tagger.dev.gov.uk/).

### Running the test suite

```
$ bundle exec rspec
```

## Licence

[MIT License](LICENCE)
