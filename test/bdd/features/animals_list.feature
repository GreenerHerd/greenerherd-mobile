Feature: Animals list interactions
  As a herd manager
  I want to filter and open animals from the list
  So that I can manage the herd without UI errors

  @positive
  Scenario: Tag filter chips toggle without errors
    Given the animals list is shown
    When the user taps the "Pregnant" filter
    Then the pregnant filter is active
    When the user taps "Any status"
    Then no tag filter is active

  @positive
  Scenario: Animal row opens profile
    Given the animals list is shown
    When the user opens animal "Mona"
    Then they see the animal profile overview
    And no framework errors occur

  @positive
  Scenario: Weaning filter then animal opens profile
    Given the animals list is shown
    When the user taps the "Weaning" filter
    And the user opens animal "Yara"
    Then they see the animal profile overview
    And no framework errors occur

  @positive
  Scenario: Species filter chips switch list
    Given the animals list is shown
    When the user taps the "Goats" species filter
    Then the goat species filter is active
