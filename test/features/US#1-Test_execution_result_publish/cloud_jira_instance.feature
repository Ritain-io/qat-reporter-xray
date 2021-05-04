@user_story#1 @xray @publish @test_execution @announce-command @announce-output @cloud
Feature: Test execution result publish - Cloud
  As a Xray user,
  In order to see my automated test results in JIRA,
  I want to publish them through Xray

  Background:
    Given I use a fixture named "cucumber_project"
    Given a environment "dummy" with version "1.0" and revision "2.0" are defined in environment
    Given a file named "config/default.yml" with:
    """
    env: 'dummy'
    """

    And a file named "features/support/env.rb" with:
    """
    require 'minitest'
    require 'qat/reporter/xray'
    require 'qat/configuration'

    QAT::Reporter::Xray.configure do |c|
      c.project_key  = 'QAD'
      c.test_prefix  = 'TEST_'
      c.story_prefix = 'STORY_'
      c.login_credentials = ['username', 'password', 'api_token']
      c.cloud_xray_api_credentials = ['client_id', 'client_secret']
      c.jira_url = 'https://domain.net'
      c.jira_type = 'cloud'
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
    Given a file named "config/dummy/xray.yml" with:
    """
    environment_name: <%= ENV['QAT_REPORTER_XRAY_BUILD_ENVIRONMENT'] %>
    version: <%= ENV['QAT_REPORTER_XRAY_BUILD_VERSION'] %>
    revision: <%= ENV['QAT_REPORTER_XRAY_BUILD_REVISION'] %>
    """
    And a file named "features/tests.feature" with:
    """
    @STORY_QAT-7 @some_tag @foo @bar
    Feature: Dummy feature 2

      @TEST_QAT-1 @other_tag @scenario1
      Scenario: scenario 2.1
        Given some conditions
        When some actions are made
        Then a result is achieved
    """


  @test#1
  Scenario: Should generate a xray test result file with scenario successful in cloud
    Given a file named "features/tests.feature" with:
    """
    @STORY_QAD-7 @some_tag @foo @bar
    Feature: Dummy feature 1

      Background: a background
        Given some pre-settings

      @TEST_QAD-1 @other_tag
      Scenario: scenario 1.1
        Given some conditions
        When some actions are made
        Then a result is achieved
    """
    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "1 scenario (1 passed)"
    And the exit status should be 0
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAD-1",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": "",
          "status": "PASSED"
        }
      \]
    }
    """
    Then the output should contain "Importing Test results to a new Test Execution."
    Then the output should match /QAT::Reporter::Xray::Publisher::Base::Client: {\n  "id": "\d+",\n  "key": "QAD-\d+",\n  "self": ".*"\n}/

  @test#2
  Scenario: Should generate a xray test result file with scenario unsuccessful in cloud
    Given a file named "features/tests.feature" with:
    """
    @STORY_QAD-7 @some_tag @foo @bar
    Feature: Tagged feature

      Background: a background
        Given some pre-settings

      @tag4534 @TEST_QAD-2
      Scenario: scenario 1.2
        Given some conditions
        When some actions are made
        Then an expected result is not achieved
    """
    And a test execution with id "QAD-7"
    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "1 scenario (1 failed)"
    And the exit status should be 1
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAD-2",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": "Expected false to be truthy. \(Minitest::Assertion\)\n.\/features\/step_definitions\/steps.rb:19[^"]+",
          "status": "FAILED"
        }
      \]
    }
    """

  @test#3
  Scenario: Should generate a xray test result file with scenario outline successful in cloud
    Given a file named "features/tests.feature" with:
    """
    @STORY_QAD-7 @some_tag @foo @bar
    Feature: Tagged feature

      @system_tag @TEST_QAD-4 @tag123
      Scenario: scenario 2.1
        Given some conditions
        When some actions are made
        Then a result is achieved
      """

    And a test execution with id "QAD-7"

    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "1 scenario (1 passed)"
    And the exit status should be 0
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAD-4",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": "",
          "status": "PASSED"
        }
      \]
    }
    """

  @test#4
  Scenario: Should generate a xray test result file with scenario outline unsuccessful in cloud (1 failed, 1 passed)
    Given a file named "features/tests.feature" with:
   """
    @STORY_QAD-7 @some_tag @foo @bar
    Feature: Tagged feature

      @tag123 @system_tag @TEST_QAD-5
      Scenario Outline: scenario outline 2.2
        Given some conditions
        When some "<action>" action is made
        Then "<result>" result is achieved

        Examples:
          | action | result |
          | good   | good   |
          | good   | bad    |
      """
    And a test execution with id "QAD-7"

    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "2 scenarios (1 failed, 1 passed)"
    And the exit status should be 1
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAD-5",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": "Expected false to be truthy. \(Minitest::Assertion\)\n.\/features\/step_definitions\/steps.rb:46.*([\n]*.)*",
          "status": "FAILED",
          "examples": \[
            "PASSED",
            "FAILED"
          \]
        }
      \]
    }
    """

  @test#5
  Scenario: Should generate a xray test result file with scenario outline unsuccessful in cloud ((1 failed, 2 passed)
    Given a file named "features/tests.feature" with:
    """
    @STORY_QAD-6 @some_tag @foo @bar
    Feature: Tagged feature

      @tag123 @system_tag @TEST_QAD-6
      Scenario Outline: scenario outline 2.3
        Given some conditions
        When some "<action>" action is made
        Then "<result>" result is achieved

        Examples:
          | action | result |
          | good   | good   |
          | good   | bad    |
          | good   | good   |
    """
    And a test execution with id "QAD-7"

    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output should contain "3 scenarios (1 failed, 2 passed)"
    And the exit status should be 1
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAD-6",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": "Expected false to be truthy. \(Minitest::Assertion\)\n.\/features\/step_definitions\/steps.rb:46.*([\n]*.)*",
          "status": "FAILED",
          "examples": \[
            "PASSED",
            "FAILED",
            "PASSED"
          \]
        }
      \]
    }
    """
    Then the output should contain "Importing Test results to Test Execution 'QAD-7'"
    Then the output should match /QAT::Reporter::Xray::Publisher::Base::Client: {\n  "id": "\d+",\n  "key": "QAD-\d+",\n  "self": ".*"\n}/

  @test#27
  Scenario: Should generate a xray test result file with scenario unsuccessful and embed text evidence in cloud
    Given a file named "features/tests.feature" with:
    """
    @STORY_QAD-7 @some_tag @foo @bar
    Feature: Tagged feature

      Background: a background
        Given some pre-settings
        And I embed evidence with source "public/test_fail.txt" with mime type "text/plain" and label "test fail txt"

      @tag4534 @TEST_QAD-2
      Scenario: scenario 2
        Given some conditions
        When some actions are made
        Then an expected result is not achieved
    """
    And a test execution with id "QAD-7"
    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "1 scenario (1 failed)"
    And the exit status should be 1
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAD-2",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": "Expected false to be truthy. \(Minitest::Assertion\)\n.\/features\/step_definitions\/steps.rb:19[^"]+",
          "status": "FAILED",
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
    Then the output should contain "Importing Test results to Test Execution 'QAD-7'"
    Then the output should match /QAT::Reporter::Xray::Publisher::Base::Client: {\n  "id": "\d+",\n  "key": "QAD-\d+",\n  "self": ".*"\n}/

  @test#28
  Scenario: Should generate a xray test result file with scenario outline unsuccessful and embed image evidence in cloud (1 failed, 1 passed)
    Given a file named "features/tests.feature" with:
    """
    @STORY_QAD-7 @some_tag @foo @bar
    Feature: Tagged feature

      Background: a background
        Given some pre-settings
        And I embed evidence with source "public/test_fail.png" with mime type "image/png" and label "test fail image"

      @tag123 @system_tag @TEST_QAD-5
      Scenario Outline: scenario 5
        Given some conditions
        When some "<action>" action is made
        Then "<result>" result is achieved

        Examples:
          | action | result |
          | good   | good   |
          | good   | bad    |
      """
    And a test execution with id "QAD-7"
    When I run `cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json`
    Then the output from "cucumber --expand --format pretty --format QAT::Formatter::Xray --out public/xray.json" should contain "2 scenarios (1 failed, 1 passed)"
    And the exit status should be 1
    And a file named "public/xray.json" should match:
    """
    {
      "tests": \[
        {
          "testKey": "QAD-5",
          "start": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "finish": "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[\+|\-]\d{2}:\d{2}",
          "comment": ".*",
          "status": "FAILED",
          "examples": \[
            "PASSED",
            "FAILED"
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
    Then the output should contain "Importing Test results to Test Execution 'QAD-7'"
    Then the output should match /QAT::Reporter::Xray::Publisher::Base::Client: {\n  "id": "\d+",\n  "key": "QAD-\d+",\n  "self": ".*"\n}/

