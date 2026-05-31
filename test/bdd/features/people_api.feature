Feature: People API integration
  Phase 6 — mobile loads team from gh-api-people.

  @positive
  Scenario: Hybrid repository maps API members
    Given a people API returns farm members
    When the hybrid people repository lists people
    Then the team includes the owner and manager

  @positive
  Scenario: API failure falls back to mock team
    Given the people API is unavailable
    When the hybrid people repository lists people
    Then the mock team is returned
