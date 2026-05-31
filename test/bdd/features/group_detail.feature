Feature: Group detail tabs
  As a herd manager
  I want a tabbed group view with overview, animals, nutrition, milking, and health
  So that I can manage a group in one place

  @positive
  Scenario: Milking group shows expected tabs
    Given group "g1" exists with milking animals
    When the group detail screen is shown
    Then tabs include "Overview", "Animals", "Nutrition", "Milking", and "Health"

  @positive
  Scenario: Overview shows purpose, milking KPIs, and nutrition summary
    Given group "g1" exists
    When the user opens the Overview tab
    Then they see "Milking KPIs"
    And they see "Nutrition"
    And they see "PURPOSE"

  @positive
  Scenario: Nutrition tab shows today vs requirement and feed
    Given group "g1" exists
    When the user opens the Nutrition tab
    Then they see "Today vs requirement"
    And they see "Today's feed"
    And they see "Energy gap detected"

  @positive
  Scenario: Milking tab shows volume and top producers
    Given group "g1" exists
    When the user opens the Milking tab
    Then they see "TODAY'S VOLUME"
    And they see "Top producers"

  @positive
  Scenario: Animals tab lists group members by name
    Given group "g1" exists
    When the user opens the Animals tab
    Then they see "Mona #0438"

  @positive
  Scenario: Tapping a young-stock animal opens its profile
    Given group "g4" detail is shown
    When the user opens the Animals tab
    And the user opens animal "Yara"
    Then no framework errors occur
    And they see the animal profile overview

  @negative
  Scenario: Unknown group shows not found
    Given group "missing" does not exist
    When the group detail screen is shown
    Then they see "Group not found"
