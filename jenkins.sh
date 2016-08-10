#!/bin/bash

export REPO_NAME=${REPO_NAME:-"alphagov/content-tagger"}
export CONTEXT_MESSAGE=${CONTEXT_MESSAGE:-"default"}
export GH_STATUS_GIT_COMMIT=${SCHEMA_GIT_COMMIT:-${GIT_COMMIT}}

curl https://raw.githubusercontent.com/alphagov/govuk-ci-scripts/master/rails-app.sh | bash
