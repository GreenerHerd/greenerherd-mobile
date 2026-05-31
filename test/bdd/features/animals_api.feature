Feature: Animals API integration
  As a farm manager
  I want the app to load animals from gh-api-animals
  So that herd data matches the backend services

  @positive
  Scenario: Hybrid repository maps API animals
    Given an animals gateway returns Holstein cow Bessie
    When I list animals from the hybrid repository
    Then animal with tag "0421" has breed "Holstein"

  @positive
  Scenario: Hybrid repository maps API groups with head counts
    Given an animals gateway returns group Milking A with 4 animals
    When I list groups from the hybrid group repository
    Then group "Milking A" has head count 4

  @positive
  Scenario: API failure uses offline animals when cache populated
    Given the animals gateway throws an error
    And offline store has animal OFF-1
    When I list animals from the hybrid repository
    Then animal with tag "OFF-1" is returned
