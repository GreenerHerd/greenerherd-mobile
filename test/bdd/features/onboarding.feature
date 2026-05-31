Feature: Mobile farm onboarding
  As a new user after social sign-in
  I want to configure my farm without choosing species upfront
  So that species are inferred when I add animals

  @positive
  Scenario: Onboarding shows linked account and farm fields
    Given onboarding is required
    And the user signed in with Google
    When the onboarding screen is shown
    Then they see "Linked to Google account"
    And they do not see species checkboxes

  @positive
  Scenario: Completing onboarding marks farm ready
    Given onboarding is required
    When the user finishes onboarding
    Then onboarding is complete

  @negative
  Scenario: Onboarding does not ask for species selection
    Given onboarding is required
    When the onboarding screen is shown
    Then "Select species on your farm" is not shown
