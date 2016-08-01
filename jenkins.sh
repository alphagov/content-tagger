#!/bin/bash

export REPO_NAME=${REPO_NAME:-"alphagov/content-tagger"}
export CONTEXT_MESSAGE=${CONTEXT_MESSAGE:-"default"}
export GH_STATUS_GIT_COMMIT=${SCHEMA_GIT_COMMIT:-${GIT_COMMIT}}

export SKIP_LINT_IN_SPECS=1

echo "Cloning govuk-ci-scripts"
rm -rf tmp/govuk-ci-scripts
git clone git@github.com:alphagov/govuk-ci-scripts.git tmp/govuk-ci-scripts
chmod +x tmp/govuk-ci-scripts/rails-app.sh

echo "Running govuk-ci-scripts/rails-app.sh"
./tmp/govuk-ci-scripts/rails-app.sh
