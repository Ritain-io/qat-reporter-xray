@STORY_DEMO-3 @some_tag @foo @bar
Feature: Tagged feature

  Background: a background
    Given some pre-settings

  @TEST_DEMO-51 @other_tag
  Scenario: scenario 1
    Given some conditions
    When some actions are made
    Then a result is achieved

  @tag456 @TEST_DEMO-52
  Scenario: scenario 2
    Given some conditions
    When some actions are made
    Then an expected result is not achieved

  @system_tag @TEST_DEMO-53 @tag123
  Scenario Outline: scenario 3
    Given some conditions
    When some "<action>" action is made
    Then "<result>" result is achieved

    Examples:
      | action | result |
      | good   | good   |
      | good   | good   |

  @tag123 @system_tag @TEST_DEMO-54
  Scenario Outline: scenario 4
    Given some conditions
    When some "<action>" action is made
    Then "<result>" result is achieved

    Examples:
      | action | result |
      | good   | good   |
      | good   | bad    |

  @tag123 @system_tag @TEST_DEMO-55
  Scenario Outline: scenario 5
    Given some conditions
    When some "<action>" action is made
    Then "<result>" result is achieved

    Examples:
      | action | result |
      | good   | good   |
      | good   | bad    |
      | good   | good   |