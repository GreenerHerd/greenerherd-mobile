Feature: Breed reference API
  As a mobile or web client
  I want to query the breed catalogue and weight curves
  So that onboarding and animal forms use consistent reference data

  Background:
    Given the animals API is running

  Scenario: List cattle breeds without authentication
    When I GET "/api/v1/reference/breeds?species=CATTLE" without auth
    Then the response status should be 200
    And the response JSON at "meta.total" should be at least 20
    And the response data includes a breed named "Holstein"

  Scenario: Get breed details by id
    Given cattle breed "Holstein" is saved as "holsteinBreedId"
    When I GET "/api/v1/reference/breeds/{holsteinBreedId}" without auth
    Then the response status should be 200
    And the response JSON at "data.name_en" should be "Holstein"
    And the response JSON at "data.species" should be "CATTLE"

  Scenario: Return 404 for unknown breed id
    When I GET "/api/v1/reference/breeds/00000000-0000-4000-8000-000000009999" without auth
    Then the response status should be 404
    And the response JSON at "error.code" should be "BREED_NOT_FOUND"

  Scenario: Breed reference health reports catalog size
    When I GET "/api/v1/reference/breeds/health" without auth
    Then the response status should be 200
    And the response JSON at "data.loaded" should be at least 90

  Scenario: Weight curve is available for a known breed
    Given cattle breed "Holstein" is saved as "holsteinBreedId"
    When I GET "/api/v1/reference/breeds/{holsteinBreedId}/weights" without auth
    Then the response status should be 200
    And the response JSON at "meta.total" should be at least 1

  Scenario: Reject invalid species filter on breed list
    When I GET "/api/v1/reference/breeds?species=CAMEL" without auth
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"
