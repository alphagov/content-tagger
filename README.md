# Content Tagger

Content Tagger is the publishing application for the [Topic Taxonomy](https://docs.publishing.service.gov.uk/manual/taxonomy.html) on GOV.UK. It also provides some functionality for tagging content in bulk.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

```
bundle exec rake
```

## Further documentation

### User account types and access permissions

The Signon permissions system is used to define 4 roles.

 - Users with the `signin` permission have a basic level of read only
   access to some functionality.
 - Users with the `Tagathon participant` permission should have access
   to the Projects section of the application, but not much outside of
   that.
 - Users with the `Managing Editor` permission should be able to view
   the Topic Taxonomy, and move content between taxons.
 - Users with the `GDS Editor` have access to all functionality.

## Licence

[MIT License](LICENCE)
