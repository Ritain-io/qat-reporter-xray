Feature: Untagged feature

  @id:23
  Scenario: this scenario also has no tags
    Given some conditions
    When some actions are made
    Then a result is achieved

  Scenario Outline: this scenario outline has no tags
    Given some conditions
    When action <action> is made
    Then <result> is achieved

    Examples: the examples
      | action  | result  |
      | action1 | result1 |
      | action2 | result2 |