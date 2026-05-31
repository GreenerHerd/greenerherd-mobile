Feature: Animal profile interactions
  As a herd manager
  I want to use profile tabs and quick actions
  So that I can manage individual animals safely

  @positive
  Scenario: Profile tabs switch without errors
    Given animal "a2" profile is shown
    When the user opens each profile tab
    Then no framework errors occur

  @positive
  Scenario: Lactating animal shows record milk quick action
    Given animal "a2" profile is shown
    When the user taps "Record milk"
    Then no framework errors occur

  @positive
  Scenario: Animal purpose dropdown is editable on overview
    Given animal "a2" profile is shown
    When the user changes animal purpose to "Milk"
    Then no framework errors occur
