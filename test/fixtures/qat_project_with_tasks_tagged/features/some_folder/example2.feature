@previous_untagged_feature
Feature: Previous untagged feature

  @common_tag @tagged_scenario
  Scenario: this scenario also has tags
    Given some conditions
    When some actions are made
    Then a result is achieved

  @common_tag
  Scenario Outline: this scenario outline has tags
    Given some conditions
    When action <action> is made
    Then result <result> is achieved

    Examples: the examples
      | action  | result  |
      | action1 | result1 |
      | action2 | result2 |