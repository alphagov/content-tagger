#!/usr/bin/env groovy

library("govuk")

node {
  govuk.setEnvar("PUBLISHING_E2E_TESTS_COMMAND", "test-content-tagger")
  govuk.buildProject(
    sassLint: false,
    rubyLintDiff: false,
    publishingE2ETests: true
  )
}
