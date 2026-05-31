Feature: Mobile sign-in and farm setup entry
  As a farm owner
  I want to sign in with social providers or start farm setup
  So that I can access my herd data

  @positive @e2e
  Scenario: Sign-in screen shows social providers and branding
    Given the user is signed out
    When the sign-in screen is shown
    Then they see "Continue with Google"
    And they see "Continue with Apple"
    And they see "Continue with Facebook"
    And they see "New farm setup"

  @positive @e2e
  Scenario: Google sign-in reaches home when onboarding is complete
    Given onboarding is already complete
    When the user taps "Continue with Google"
    Then a session is created

  @positive
  Scenario: New farm setup links Google and opens onboarding
    Given the user is signed out
    When the user taps "New farm setup"
    Then onboarding is not complete
    And a Google account is linked

  @negative
  Scenario: Signed-out user has no session
    Given the user is signed out
    Then there is no active session
