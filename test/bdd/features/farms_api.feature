Feature: Farms API integration
  Phase 6 — mobile loads farm profile from gh-api-farms.

  @positive
  Scenario: Hybrid repository maps API farm profile
    Given a farms API returns Al-Falah profile
    When the hybrid farm repository loads the current farm
    Then the farm name is Al-Falah Farm

  @positive
  Scenario: API failure falls back to mock farm
    Given the farms API is unavailable
    When the hybrid farm repository loads the current farm
    Then the mock farm name is returned
