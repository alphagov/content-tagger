#!/usr/bin/env groovy

library("govuk@remove-master-branch-quirk")

node {
  govuk.setEnvar("PUBLISHING_E2E_TESTS_COMMAND", "test-content-tagger")
  govuk.buildProject(
    publishingE2ETests: true,
    brakeman: true
  )

  // Run against the PostgreSQL 13 Docker instance on GOV.UK CI
  govuk.setEnvar("TEST_DATABASE_URL", "postgresql://postgres@127.0.0.1:54313/content_tagger_test")
}
