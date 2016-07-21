#!/bin/bash

export REPO_NAME="alphagov/govuk-content-schemas"
export CONTEXT_MESSAGE="Verify content-tagger against content schemas"

exec ./jenkins.sh
