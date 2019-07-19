@tagged_feature
Feature: Tagged feature

  Background: a background
    Given some pre-settings

  @tagged_scenario
  Scenario: this scenario has tags
    Given some conditions
    When some actions are made
    Then a result is achieved

  Scenario: this scenario has no tags
    Given some conditions
    When some actions are made
    Then a result is achieved
