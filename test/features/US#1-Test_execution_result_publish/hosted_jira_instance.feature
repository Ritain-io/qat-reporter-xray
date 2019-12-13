@user_story#1 @xray @publish @test_execution @announce-command @announce-output @hosted
Feature: Test execution result publish - Hosted
  As a Xray user,
  In order to see my automated test results in JIRA,
  I want to publish them through Xray

  Background:
    Given I use a fixture named "cucumber_project"
    And a file named "features/support/env.rb" with:
    """
    require 'minitest'
    require 'qat/reporter/xray'

    QAT::Reporter::Xray.configure do |c|
      c.project_key  = 'QAT'
      c.test_prefix  = 'TEST_'
      c.story_prefix = 'STORY_'
      c.login_credentials = ['username', 'password', 'api_token']
      c.jira_type = 'hosted'
      c.jira_url = 'http://test.jira.com'
      c.xray_test_environment = 'dummy'
      c.xray_test_version = '1.0'
      c.xray_test_revision = '1.0'
    end

    module Tests
      class Cucumber
        include QAT::Logger
        include Minitest::Assertions

        attr_writer :assertions

        def assertions
          @assertions ||= 0
        end
      end
    end

    World { ::Tests::Cucumber.new }

    """

  @test#6
  Scenario: Should generate a xray test result file with scenario successful
    Given a file named "features/tests.feature" with:
    """
    @STORY_QAT-1 @some_tag @foo @bar
    Feature: Tagged feature

      Background: a background
        Given some pre-settings

      @TEST_QAT-1 @other_tag
      Scenario: scenario 1
        Given some conditions
        When some actions are made
        Then a result is achieved
    """
    And no test execution exists
    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "1 scenario (1 passed)"
    And the exit status should be 0
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAT-1",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": "",
          "status": "PASS"
        }
      \]
    }
    """

  @test#32
  Scenario: Should fail test execution on error communicating with jira
    Given a file named "features/tests.feature" with:
    """
    @STORY_QAT-1 @some_tag @foo @bar
    Feature: Tagged feature

      Background: a background
        Given some pre-settings

      @TEST_QAT-1 @other_tag
      Scenario: scenario 1
        Given some conditions
        When some actions are made
        Then a result is achieved
    """
    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "1 scenario (1 passed)"
    And the exit status should be 2
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAT-1",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": "",
          "status": "PASS"
        }
      \]
    }
    """

  @test#7
  Scenario: Should generate a xray test result file with scenario unsuccessful
    Given a file named "features/tests.feature" with:
    """
    @STORY_QAT-1 @some_tag @foo @bar
    Feature: Tagged feature

      Background: a background
        Given some pre-settings

      @tag4534 @TEST_QAT-2
      Scenario: scenario 2
        Given some conditions
        When some actions are made
        Then an expected result is not achieved
    """
    And a test execution with id "QAT-7"

    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "1 scenario (1 passed)"
    And the exit status should be 1
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAT-2",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": "Expected false to be truthy. \(Minitest::Assertion\)\n.\/features\/step_definitions\/steps.rb:19[^"]+",
          "status": "FAIL"
        }
      \]
    }
    """

  @test#32
  Scenario: Should fail test execution on error communicating with jira
    Given a file named "features/tests.feature" with:
    """
    @STORY_QAT-1 @some_tag @foo @bar
    Feature: Tagged feature

      Background: a background
        Given some pre-settings

      @TEST_QAT-1 @other_tag
      Scenario: scenario 1
        Given some conditions
        When some actions are made
        Then a result is achieved
    """
    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "1 scenario (1 passed)"
    And the exit status should be 2

  @test#8
  Scenario: Should generate a xray test result file with scenario outline successful
    Given a file named "features/tests.feature" with:
    """
    @STORY_QAT-1 @some_tag @foo @bar
    Feature: Tagged feature

      Background: a background
        Given some pre-settings

      @system_tag @TEST_QAT-2 @tag123
      Scenario Outline: scenario 3
        Given some conditions
        When some "<action>" action is made
        Then "<result>" result is achieved

        Examples:
          | action | result |
          | good   | good   |
          | good   | good   |
      """
    And a test execution with id "QAT-7"

    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "2 scenarios (2 passed)"
    And the exit status should be 0
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAT-2",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": "",
          "status": "PASS",
          "examples": \[
            "PASS",
            "PASS"
          \]
        }
      \]
    }
    """

  @test#9
  Scenario: Should generate a xray test result file with scenario outline unsuccessful (1 failed, 1 passed)
    Given a file named "features/tests.feature" with:
   """
    @STORY_QAT-1 @some_tag @foo @bar
    Feature: Tagged feature

      Background: a background
        Given some pre-settings

      @tag123 @system_tag @TEST_QAT-5
      Scenario Outline: scenario 4
        Given some conditions
        When some "<action>" action is made
        Then "<result>" result is achieved

        Examples:
          | action | result |
          | good   | good   |
          | good   | bad    |
      """
    And a test execution with id "QAT-7"

    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "2 scenarios (1 failed, 1 passed)"
    And the exit status should be 1
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAT-5",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": "Expected false to be truthy. \(Minitest::Assertion\)\n.\/features\/step_definitions\/steps.rb:46.*([\n]*.)*",
          "status": "FAIL",
          "examples": \[
            "PASS",
            "FAIL"
          \]
        }
      \]
    }
    """

  @test#10
  Scenario: Should generate a xray test result file with scenario outline unsuccessful (1 failed, 2 passed)
    Given a file named "features/tests.feature" with:
    """
    @STORY_QAT-1 @some_tag @foo @bar
    Feature: Tagged feature

      Background: a background
        Given some pre-settings

      @tag123 @system_tag @TEST_QAT-1
      Scenario Outline: scenario 5
        Given some conditions
        When some "<action>" action is made
        Then "<result>" result is achieved

        Examples:
          | action | result |
          | good   | good   |
          | good   | bad    |
          | good   | good   |
    """
    And a test execution with id "QAT-7"

    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "3 scenarios (1 failed, 2 passed)"
    And the exit status should be 1
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAT-1",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": ".*",
          "status": "FAIL",
          "examples": \[
            "PASS",
            "FAIL",
            "PASS"
          \]
        }
      \]
    }
    """
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "Importing Test results to Test Execution 'QAT-7'"
    Then the output should match /QAT::Reporter::Xray::Publisher::Base::Client: {\n  "testExecIssue": {\n    "id": "\d+",\n    "key": "QAT-\d+",\n    "self": ".*"\n  }\n}/

  @test#30
  Scenario: Should generate a xray test result file with scenario successful and embed text evidence
    Given a file named "features/tests.feature" with:
    """
    @STORY_QAT-1 @some_tag @foo @bar
    Feature: Tagged feature

      Background: a background
        Given some pre-settings
        And I embed evidence with source "public/test_fail.txt" with mime type "text/plain" and label "test fail text"

      @TEST_QAT-1 @other_tag
      Scenario: scenario 1
        Given some conditions
        When some actions are made
        Then a result is achieved
    """
    And a test execution with id "QAT-7"

    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "1 scenario (1 passed)"
    And the exit status should be 0
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAT-1",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": "",
          "status": "PASS",
          "evidences": \[
            {
              "data": ".*",
              "filename": ".*.txt",
              "contentType": "text/plain"
            }
          \]
        }
      \]
    }
    """
    Then the output should contain "Importing Test results to Test Execution 'QAT-7'"
    Then the output should match /QAT::Reporter::Xray::Publisher::Base::Client: {\n  "testExecIssue": {\n    "id": "\d+",\n    "key": "QAT-\d+",\n    "self": ".*"\n  }\n}/

  @test#31
  Scenario: Should generate a xray test result file with scenario outline unsuccessful and embed image evidence (1 failed, 1 passed)
    Given a file named "features/tests.feature" with:
   """
    @STORY_QAT-1 @some_tag @foo @bar
    Feature: Tagged feature

      Background: a background
        Given some pre-settings
        And I embed evidence with source "public/test_fail.png" with mime type "image/png" and label "test fail image"

      @tag123 @system_tag @TEST_QAT-5
      Scenario Outline: scenario 4
        Given some conditions
        When some "<action>" action is made
        Then "<result>" result is achieved

        Examples:
          | action | result |
          | good   | good   |
          | good   | bad    |
      """
    And a test execution with id "QAT-7"

    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "2 scenarios (1 failed, 1 passed)"
    And the exit status should be 1
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAT-5",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": ".*",
          "status": "FAIL",
          "examples": \[
            "PASS",
            "FAIL"
          \],
          "evidences": \[
            {
              "data": ".*",
              "filename": ".*.png",
              "contentType": "image/png"
            }
          \]
        }
      \]
    }
    """
    Then the output should contain "Importing Test results to Test Execution 'QAT-7'"
    Then the output should match /QAT::Reporter::Xray::Publisher::Base::Client: {\n  "testExecIssue": {\n    "id": "\d+",\n    "key": "QAT-\d+",\n    "self": ".*"\n  }\n}/

#  @test#11
#  Scenario: Should generate a xray test result file with scenario outline unsuccessful and embed video evidence (1 failed, 2 passed)
#    Given a file named "features/tests.feature" with:
#    """
#    @STORY_QAT-1 @some_tag @foo @bar
#    Feature: Tagged feature
#
#      Background: a background
#        Given some pre-settings
#        And I embed evidence with source "public/test_fail.mp4" with mime type "video/mp4" and label "test fail video"
#
#      @tag123 @system_tag @TEST_QAT-5
#      Scenario Outline: scenario 5
#        Given some conditions
#        When some "<action>" action is made
#        Then "<result>" result is achieved
#
#        Examples:
#          | action | result |
#          | good   | good   |
#          | good   | bad    |
#          | good   | good   |
#    """
#    And no test execution exists
#    And a test execution with id "QAT-7"
#
#    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
#    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "3 scenarios (1 failed, 2 passed)"
#    And the exit status should be 1
#    And a file named "public/xray.json" should match:
#    """
#    {
#      "tests": \[
#        {
#          "testKey": "QAT-5",
#          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
#          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
#          "comment": ".*",
#          "status": "FAIL",
#          "examples": \[
#            "PASS",
#            "FAIL",
#            "PASS"
#          \],
#          "evidences": \[
#            {
#              "data": ".*",
#              "filename": ".*.mp4",
#              "contentType": "video/mp4"
#            }
#          \]
#        }
#      \]
#    }
#    """
#    Then the output should contain "Importing Test results to Test Execution 'QAT-7'"
#    Then the output should match /QAT::Reporter::Xray::Publisher::Base::Client: {\n  "testExecIssue": {\n    "id": "\d+",\n    "key": "QAT-\d+",\n    "self": ".*"\n  }\n}/
