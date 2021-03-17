# Content Tagger

Content Tagger is the publishing application for the Topic Taxonomy on
GOV.UK. It also provides some functionality for tagging content in
bulk.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

```
bundle exec rake
```

## Features

### Managing the Topic Taxonomy

Content Tagger can create, edit and unpublish taxons. It also can view
the content tagged to a taxon, and how this has changed over time.

Read [How the topic taxonomy works](https://docs.publishing.service.gov.uk/manual/taxonomy.html).

### Tagging content

Content Tagger has a "Projects" function for tagging content in bulk
to the Topic Taxonomy. It also supports tagging individual pages.

## Screenshots

### Tagging content

![Tagging content](docs/screenshots/taggings.png)

### Taxons

![Taxons](docs/screenshots/taxons.png)

### Education taxon

![Education taxon](docs/screenshots/education-taxon.png)

### Bubbles visualisation

![Bubbles visualisation](docs/screenshots/education-taxon-bubbles.png)

### List visualisation

![List visualisation](docs/screenshots/education-taxon-list.png)

### Editing a taxon

![Editing a taxon](docs/screenshots/education-taxon-edit.png)

### Tagging projects

![Tagging projects](docs/screenshots/projects.png)

## Dependencies

- [alphagov/publishing-api](https://github.com/alphagov/publishing-api)

## Licence

[MIT License](LICENCE)
