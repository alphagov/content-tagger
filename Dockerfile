FROM ruby:2.4.2
RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y build-essential nodejs && apt-get clean

ENV DATABASE_URL postgresql://postgres@postgres/content-tagger
ENV GOVUK_APP_NAME content-tagger
ENV PORT 3116
ENV RAILS_ENV development
ENV REDIS_HOST redis

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

RUN GOVUK_APP_DOMAIN=www.gov.uk GOVUK_APP_DOMAIN_EXTERNAL=www.gov.uk RAILS_ENV=production bundle exec rails assets:precompile

HEALTHCHECK CMD curl --silent --fail localhost:$PORT || exit 1

CMD bash -c "bundle exec unicorn -p $PORT"
