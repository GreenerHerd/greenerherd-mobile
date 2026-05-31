Feature: Breed reference API on farms service
  As a client using the farms gateway
  I want the same breed catalogue endpoints
  So that reference data is available without calling the animals service

  Background:
    Given the farms API is running

  Scenario: List sheep breeds without authentication
    When I GET "/api/v1/reference/breeds?species=SHEEP" without auth
    Then the response status should be 200
    And the response JSON at "meta.total" should be at least 25
    And the response data includes a breed named "Najdi"

  Scenario: Breed reference health on farms service
    When I GET "/api/v1/reference/breeds/health" without auth
    Then the response status should be 200
    And the response JSON at "data.loaded" should be at least 90
