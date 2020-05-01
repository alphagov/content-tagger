#!/usr/bin/env groovy

library("govuk")

node("postgresql-9.3") {
  govuk.setEnvar("PUBLISHING_E2E_TESTS_COMMAND", "test-content-tagger")
  govuk.buildProject(
    sassLint: false,
    rubyLintDirs: "",
    publishingE2ETests: true,
    brakeman: true,
  )
}
