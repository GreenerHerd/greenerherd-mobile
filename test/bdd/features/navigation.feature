Feature: Cross-screen animal navigation
  As a herd manager
  I want to open animal profiles from groups and lists
  So that navigation never crashes with duplicate route keys

  @positive
  Scenario: Young stock group animal opens profile without navigator errors
    Given group "g4" detail is shown
    When the user opens the Animals tab
    And the user opens animal "Yara"
    Then no framework errors occur
    And they see the animal profile overview

  @positive
  Scenario: Milking group animal opens profile from animals tab
    Given group "g1" detail is shown
    When the user opens the Animals tab
    And the user opens animal "Mona"
    Then no framework errors occur

  @positive
  Scenario: Animals list opens weaning calf profile
    Given the animals list is shown
    When the user taps the "Weaning" filter
    And the user opens animal "Yara"
    Then no framework errors occur
    And they see the animal profile overview

  @positive
  Scenario: Opening two animals in sequence does not duplicate route keys
    Given group "g4" detail is shown
    When the user opens the Animals tab
    And the user opens animal "Yara"
    And the user goes back
    And the user opens animal "Yara" again
    Then no framework errors occur
