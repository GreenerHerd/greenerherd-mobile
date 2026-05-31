Feature: Farm onboarding
  As a new farm owner
  I want to set up my farm profile and species
  So that I can start managing livestock

  Background:
    Given the farms API is running
    And I am authenticated as farm owner "owner-1"

  Scenario: Create a new farm (onboarding step 1)
    When I POST "/api/v1/farms" with body:
      """
      {
        "name": "Al-Falah Farm",
        "country": "SA",
        "housing_type": "INDOOR_FANS",
        "preferred_currency": "SAR",
        "preferred_lang": "EN",
        "location_lat": 24.7136,
        "location_lng": 46.6753
      }
      """
    Then the response status should be 201
    And the response JSON at "data.name" should be "Al-Falah Farm"
    And the response JSON at "data.onboarding_completed" should be false
    And I save "data.id" as "farmId"

  Scenario: Add species to farm (onboarding step 2)
    Given a farm exists with id "farm-step2"
    And my token includes farm "farm-step2"
    When I POST "/api/v1/farms/farm-step2/species" with body:
      """
      { "species": "CATTLE", "purpose": "MILK" }
      """
    Then the response status should be 201
    And the response JSON at "data.species" should be "CATTLE"
    When I GET "/api/v1/farms/farm-step2/species"
    Then the response status should be 200
    And the response JSON at "meta.total" should be 1

  Scenario: Cannot add duplicate species
    Given a farm exists with id "farm-dup"
    And farm "farm-dup" has species CATTLE for MILK
    And my token includes farm "farm-dup"
    When I POST "/api/v1/farms/farm-dup/species" with body:
      """
      { "species": "CATTLE", "purpose": "MEAT" }
      """
    Then the response status should be 409
    And the response JSON at "error.code" should be "SPECIES_ALREADY_EXISTS"

  Scenario: Onboarding status reflects progress
    Given a farm exists with id "farm-status"
    And farm "farm-status" has species GOAT for BOTH
    And my token includes farm "farm-status"
    When I GET "/api/v1/farms/farm-status/onboarding/status"
    Then the response status should be 200
    And the response JSON at "data.step_1_farm_profile" should be true
    And the response JSON at "data.step_2_species" should be true
    And the response JSON at "data.onboarding_completed" should be false

  Scenario: Complete onboarding with skip animals (step 3C)
    Given a farm exists with id "farm-complete"
    And farm "farm-complete" has species SHEEP for MEAT
    And my token includes farm "farm-complete"
    When I POST "/api/v1/farms/farm-complete/onboarding/complete" with body:
      """
      { "skip_animals": true }
      """
    Then the response status should be 200
    And the response JSON at "data.onboarding_completed" should be true

  Scenario: Cannot complete onboarding without species
    Given a farm exists with id "farm-nospecies"
    And my token includes farm "farm-nospecies"
    When I POST "/api/v1/farms/farm-nospecies/onboarding/complete" with body:
      """
      { "skip_animals": true }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "ONBOARDING_INCOMPLETE"

  Scenario: Reject unauthenticated farm access
    Given I have no auth token
    When I GET "/api/v1/farms/any-farm"
    Then the response status should be 401
