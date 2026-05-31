Feature: Feed indicative pricing
  As a nutrition optimizer
  I need indicative regional prices stored separately from product nutrition
  So that pass-2 can minimize cost using updatable market data

  Background:
    Given the nutrition API is running

  Scenario: List indicative prices for Saudi Arabia
    When I GET "/api/v1/reference/feeds/prices?country=SA"
    Then the response status should be 200
    And the response JSON at "meta.total" should be at least 60
    And the response JSON at "meta.country_code" should be "SA"

  Scenario: Get FX reference rates
    When I GET "/api/v1/reference/feeds/fx-rates"
    Then the response status should be 200
    And the response JSON at "meta.total" should be at least 15

  Scenario: Eligible feeds include indicative pricing when country is provided
    When I POST "/api/v1/feeds/eligible" with body:
      """
      {
        "species": "CATTLE",
        "age_months": 36,
        "production_focus": "MILK",
        "lactating": true,
        "country_code": "SA"
      }
      """
    Then the response status should be 200
    And the response JSON at "data.optimizer_pass" should be "pending"
    And the eligible products include pricing for country "SA"
