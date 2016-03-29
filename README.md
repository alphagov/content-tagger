# Content Tagger

App for tagging content on GOV.UK.

## Screenshots

![Lookup form](docs/screenshot-1.png)
![Tagging interface](docs/screenshot-2.png)

## Technical documentation

This is a Ruby on Rails application that works with the publishing-api to manage the "links hash" for content on GOV.UK.

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
