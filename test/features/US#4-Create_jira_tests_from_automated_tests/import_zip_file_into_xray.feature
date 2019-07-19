@user_story#4 @announce-command @announce-output
Feature: User Story #4: Create jira tests based on existing automated tests - Import zip file into xray
  In order to import a zip of features into xray
  As a test developer
  I want to execute a rake task to publish the features

  @test#22
  Scenario: Generate a zip with all features
    Given I use a fixture named "qat_project_dummy_features"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |
    When I run `rake qat:\reporter:xray:tests:zip_features`
    Then the output should match:
    """
    features\/.*.feature
    """
    And a 643 byte file named "features.zip" should exist
    And the exit status should be 0

  @test#23
  Scenario: Import tests into Jira hosted
    Given I use a fixture named "qat_project_dummy_features"
    And I set the environment variables to:
      | variable        | value    |
      | CUCUMBER_FORMAT |          |
      | CUCUMBER_OPTS   |          |
      | JIRA_PASSWORD   | password |
    When I run `rake qat:\reporter:xray:tests:import_features[username,test.jira.com,hosted,QAT]`
    Then the output should match:
    """
      {
        "id": "\d+",
        "key": ".*",
        "self": ".*"
      }
    """
    And the exit status should be 0

  @test#24
  Scenario: Import tests into Jira cloud
    Given I use a fixture named "qat_project_dummy_features"
    And I set the environment variables to:
      | variable        | value         |
      | CUCUMBER_FORMAT |               |
      | CUCUMBER_OPTS   |               |
      | JIRA_PASSWORD   | client_secret |
    When I run `rake qat:\reporter:xray:tests:import_features[client_id,https://domain.net,cloud,QAD]`
    Then the output should match:
    """
    {
      "errors": \[

      \],
      "updatedOrCreatedTests": \[
        {
          "id": "\d+",
          "key": ".*",
          "self": ".*"
        },
        {
          "id": "\d+",
          "key": ".*",
          "self": ".*"
        },
        {
          "id": "\d+",
          "key": ".*",
          "self": ".*"
        },
        {
          "id": "\d+",
          "key": ".*",
          "self": ".*"
        },
        {
          "id": "\d+",
          "key": ".*",
          "self": ".*"
        }
      \],
      "updatedOrCreatedPreconditions": \[
        {
          "id": "\d+",
          "key": ".*",
          "self": ".*"
        }
      \]
    }
    """
    And the exit status should be 0