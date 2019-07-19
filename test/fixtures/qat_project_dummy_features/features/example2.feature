@dummy_feature2
Feature: Dummy feature 2

  @scenario1
  Scenario: scenario 2.1
    Given some conditions
    When some actions are made
    Then a result is achieved

  @scenario2
  Scenario Outline: scenario outline 2.2
    Given some conditions
    When some "<action>" action is made
    Then "<result>" result is achieved

    Examples:
      | action | result |
      | good   | good   |
      | good   | bad    |

  @scenario3
  Scenario Outline: scenario outline 2.3
    Given some conditions
    When some "<action>" action is made
    Then "<result>" result is achieved

    Examples:
      | action | result |
      | good   | good   |
      | good   | bad    |
      | good   | good   |