Feature: Add animal sheet
  As a farm manager
  I want the add-animal form to validate before saving
  So that bad data never enters the herd list

  @positive @e2e
  Scenario: Valid animal is saved to the herd
    Given the add animal sheet is open
    When the user enters tag "BDD99" and weight "350"
    And saves the animal
    Then the sheet closes
    And tag "BDD99" exists in the herd

  @negative @e2e
  Scenario: Empty tag shows validation error
    Given the add animal sheet is open
    When the user leaves tag empty and weight "400"
    And attempts to save
    Then they see "Tag number is required"

  @negative
  Scenario: Negative weight shows validation error
    Given the add animal sheet is open
    When the user enters tag "BDD98" and weight "-10"
    And attempts to save
    Then they see "greater than zero"

  @negative
  Scenario: Duplicate tag shows validation error
    Given the add animal sheet is open
    When the user enters tag "0438" and weight "400"
    And attempts to save
    Then they see "already in use"

  @positive
  Scenario: Animal wizard step 2 shows breed dropdown
    Given the add animal sheet is open
    When the user advances to the breed step
    Then they see a breed dropdown with "Jersey"

  @positive
  Scenario: Group sheet livestock step shows breed dropdown
    Given the add group sheet is open on the livestock step
    When the user selects new born livestock
    Then they see a breed dropdown with "Jersey"

  @positive
  Scenario: Group wizard herd step shows breed dropdown
    Given the add group wizard is open on the herd step
    Then they see a breed dropdown with "Jersey"

  @positive
  Scenario: Group wizard member status icons open dialogs without errors
    Given the add group wizard is on the animals step
    When the user taps the pregnancy status icon
    Then they see the pregnancy dialog

  @negative
  Scenario: Empty group name shows validation error
    Given the add group sheet is open
    When the user leaves the group name empty
    And attempts to save
    Then they see "Group name is required"

  @positive
  Scenario: Lowercase group name advances sheet to livestock step
    Given the add group sheet is open
    When the user enters group name "newbies"
    And continues to the livestock step
    Then they see "Step 2 of 2"
    And no framework errors occur

  @positive
  Scenario: Lowercase group name advances wizard to herd step
    Given the add group wizard is open
    When the user enters group name "newbies"
    And continues to the herd step
    Then they see "Step 2 of 3"
    And no framework errors occur

  @positive
  Scenario: Group wizard completes three steps with lowercase name
    Given the add group wizard is open
    When the user enters group name "newbies"
    And completes the herd step with head count 1
    Then they see "Step 3 of 4"
    And no framework errors occur

  @positive
  Scenario: Group wizard step 3 has no per-animal purpose field
    Given the add group wizard is open on a phone-width screen
    When the user completes steps to individual animals with head count 2
    Then they see "Step 3 of 4"
    And they do not see "Animal purpose" on that step
    And the layout has no overflow errors
