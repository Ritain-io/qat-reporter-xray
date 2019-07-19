@user_story#5 @announce-command @announce-output
Feature: User Story #5: Export xray test scenarios
  As a user,
  In order to include test scenarios in QAT project,
  I want to export this scenarios from Jira Xray

  @test#25
  Scenario: Export xray test scenarios cloud
    Given I use a fixture named "qat_project_dummy_features"
    And I set the environment variables to:
      | variable        | value         |
      | CUCUMBER_FORMAT |               |
      | CUCUMBER_OPTS   |               |
      | JIRA_PASSWORD   | client_secret |
    When I run `rake qat:\reporter:xray:tests:export_xray_test_scenarios[client_id,https://domain.net,cloud,QAD,QAD-1;QAD-2;QAD-4;QAD-5,nil]`
    Then the output should contain ".feature was found, extracting"
    And a file matching %r<.*QAD.*.feature> should exist
    And the exit status should be 0
