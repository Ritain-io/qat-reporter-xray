@user_story#4 @announce-command @announce-output
Feature: User Story #4: Create jira tests based on existing automated tests - Automatic unique test ids generation
  In order to give all test scenarios a unique identifier
  As a test developer
  I want to execute a rake task to generate test ids


  @test#12
  Scenario: Get a report on test ids in test scenarios in a project without test ids
    Given I use a fixture named "qat_project_with_tasks_tagged"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |
    When I run `rake qat:\reporter:xray:tests:report_test_ids`
    Then a file named "./public/xray_test_ids.json" should contain:
    """
    {
     "max": 0,
     "untagged": {
      "this scenario has tags": "features/example1.feature:8",
      "this scenario has no tags": "features/example1.feature:13",
      "this scenario also has tags": "features/some_folder/example2.feature:5",
      "this scenario outline has tags": "features/some_folder/example2.feature:11"
     },
     "mapping": {
     },
     "duplicate": {
     }
    }
    """
    And the exit status should be 0


  @test#13
  Scenario: Give test ids to test scenarios in a project without test ids
    Given I use a fixture named "qat_project_with_tasks_tagged"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |
    When I run `rake qat:reporter:xray:tests:generate_test_ids`
    Then the output should match:
    """
    ^Disabling profiles...
    Giving test ids to scenarios:
    {
     "features/example1.feature": \[  8,  13\],
     "features/some_folder/example2.feature": \[  5,  11\]
    }
    """
    And a file named "./public/xray_test_ids.json" should contain:
    """
    {
     "max": 0,
     "untagged": {
      "this scenario has tags": "features/example1.feature:8",
      "this scenario has no tags": "features/example1.feature:13",
      "this scenario also has tags": "features/some_folder/example2.feature:5",
      "this scenario outline has tags": "features/some_folder/example2.feature:11"
     },
     "mapping": {
     },
     "duplicate": {
     }
    }
    """
    And the exit status should be 0


  @test#14
  Scenario: Get a report on test ids of test scenarios after giving test ids in a project without test ids
    Given I use a fixture named "qat_project_with_tasks_tagged"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |
    And I run `rake qat:reporter:xray:tests:generate_test_ids`
    And the output should match:
    """
    ^Disabling profiles...
    Giving test ids to scenarios:
    {
     "features/example1.feature": \[  8,  13\],
     "features/some_folder/example2.feature": \[  5,  11\]
    }
    """
    When I run `rake qat:reporter:xray:tests:report_test_ids`
    Then a file named "./public/xray_test_ids.json" should contain:
    """
    {
     "max": 4,
     "untagged": {
     },
     "mapping": {
      "1": {
       "name": "this scenario has tags",
       "path": "features/example1.feature:8"
      },
      "2": {
       "name": "this scenario has no tags",
       "path": "features/example1.feature:14"
      },
      "3": {
       "name": "this scenario also has tags",
       "path": "features/some_folder/example2.feature:5"
      },
      "4": {
       "name": "this scenario outline has tags",
       "path": "features/some_folder/example2.feature:11"
      }
     },
     "duplicate": {
     }
    }
    """
    And the exit status should be 0


  @test#15
  Scenario: Get a report on test ids in test scenarios in a project with existing test ids
    Given I use a fixture named "qat_project_max_test_id"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |
    When I run `rake qat:reporter:xray:tests:report_test_ids`
    Then a file named "./public/xray_test_ids.json" should contain:
    """
    {
     "max": 23,
     "untagged": {
      "this scenario has tags": "features/example1.feature:8",
      "this scenario has no tags": "features/example1.feature:13",
      "this scenario outline has no tags": "features/example2.feature:9"
     },
     "mapping": {
      "23": {
       "name": "this scenario also has no tags",
       "path": "features/example2.feature:4"
      }
     },
     "duplicate": {
     }
    }
    """
    And the exit status should be 0


  @test#16
  Scenario: Give test ids to test scenarios in a project with existing test ids
    Given I use a fixture named "qat_project_max_test_id"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |
    When I run `rake qat:reporter:xray:tests:generate_test_ids`
    Then the output should match:
    """
    ^Disabling profiles...
    Giving test ids to scenarios:
    {
     "features/example1.feature": \[  8,  13\],
     "features/example2.feature": \[  9\]
    }
    """
    And a file named "./public/xray_test_ids.json" should contain:
    """
    {
     "max": 23,
     "untagged": {
      "this scenario has tags": "features/example1.feature:8",
      "this scenario has no tags": "features/example1.feature:13",
      "this scenario outline has no tags": "features/example2.feature:9"
     },
     "mapping": {
      "23": {
       "name": "this scenario also has no tags",
       "path": "features/example2.feature:4"
      }
     },
     "duplicate": {
     }
    }
    """
    And the exit status should be 0

  @testing @test#17
  Scenario: Get a report on test ids of test scenarios after giving test ids in a project already with test ids
    Given I use a fixture named "qat_project_max_test_id"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |
    And I run `rake qat:reporter:xray:tests:generate_test_ids`
    And the output should match:
    """
    ^Disabling profiles...
    Giving test ids to scenarios:
    {
     "features/example1.feature": \[  8,  13\],
     "features/example2.feature": \[  9\]
    }
    """
    When I run `rake qat:reporter:xray:tests:report_test_ids`
    Then a file named "./public/xray_test_ids.json" should contain:
    """
    {
     "max": 26,
     "untagged": {
     },
     "mapping": {
      "23": {
       "name": "this scenario also has no tags",
       "path": "features/example2.feature:4"
      },
      "24": {
       "name": "this scenario has tags",
       "path": "features/example1.feature:8"
      },
      "25": {
       "name": "this scenario has no tags",
       "path": "features/example1.feature:14"
      },
      "26": {
       "name": "this scenario outline has no tags",
       "path": "features/example2.feature:10"
      }
     },
     "duplicate": {
     }
    }
    """
    And the exit status should be 0


  @test#18
  Scenario: Get a report on test ids in test scenarios in a project without features
    Given I use a fixture named "qat_project_without_features"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |
    When I run `rake qat:reporter:xray:tests:report_test_ids`
    Then a file named "./public/xray_test_ids.json" should contain:
    """
    {
     "max": 0,
     "untagged": {
     },
     "mapping": {
     },
     "duplicate": {
     }
    }
    """
    And the exit status should be 0


  @test#19
  Scenario: Give test ids to test scenarios in a project without features
    Given I use a fixture named "qat_project_without_features"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |
    When I run `rake qat:reporter:xray:tests:generate_test_ids`
    Then the output should match:
    """
    ^Disabling profiles...
    There are no scenarios without test id.
    """
    And a file named "public/xray_test_ids.json" should contain:
    """
    {
     "max": 0,
     "untagged": {
     },
     "mapping": {
     },
     "duplicate": {
     }
    }
    """
    And the exit status should be 0


  @test#20
  Scenario: Get a report on test ids in test scenarios in a project without test ids and no scenarios with steps
    Given I use a fixture named "qat_project_with_tasks_empty_scenario"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |
    When I run `rake qat:reporter:xray:tests:report_test_ids`
    Then a file named "./public/xray_test_ids.json" should contain:
    """
    {
     "max": 0,
     "untagged": {
     },
     "mapping": {
     },
     "duplicate": {
     }
    }
    """
    And the exit status should be 0


  @test#21
  Scenario: Give test ids to test scenarios in a project without test ids and no scenarios with steps
    Given I use a fixture named "qat_project_with_tasks_empty_scenario"
    And I set the environment variables to:
      | variable        | value |
      | CUCUMBER_FORMAT |       |
      | CUCUMBER_OPTS   |       |
    When I run `rake qat:reporter:xray:tests:generate_test_ids`
    Then the output should match:
    """
    ^Disabling profiles...
    There are no scenarios without test id.
    """
    And a file named "./public/xray_test_ids.json" should contain:
    """
    {
     "max": 0,
     "untagged": {
     },
     "mapping": {
     },
     "duplicate": {
     }
    }
    """
    And the exit status should be 0