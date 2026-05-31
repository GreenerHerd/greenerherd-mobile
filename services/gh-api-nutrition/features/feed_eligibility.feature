Feature: Feed eligibility (product-suggestions feeds-with-eligibility.json patterns)
  Pass 1 filters products by species, age, sex, lactation, and production focus
  before the optimizer runs.

  Background:
    Given the nutrition API is running
    And the feed catalog has at least 60 products with eligibility rules

  Scenario: Lactating dairy cow — eligible feeds include lactation products
    When I POST "/api/v1/feeds/eligible" with body:
      """
      {
        "species": "CATTLE",
        "sex": "FEMALE",
        "age_months": 36,
        "production_focus": "MILK",
        "lactating": true
      }
      """
    Then the response status should be 200
    And the response JSON at "data.optimizer_pass" should be "pending"
    And the response JSON at "data.summary.eligible_count" should be at least 20
    And eligible feed "Steamed Corn Flake" is included for dairy cattle
    And eligible feed "Steamed Corn Flake" includes eligibility rules in the response

  Scenario: Dry dairy cow — lactation-only concentrates excluded
    When I POST "/api/v1/feeds/eligible" with body:
      """
      {
        "species": "CATTLE",
        "sex": "FEMALE",
        "age_months": 48,
        "production_focus": "MILK",
        "lactating": false
      }
      """
    Then the response status should be 200
    And eligible feed "Steamed Corn Flake" is excluded for dry cattle

  Scenario: Sheep — cattle-only products excluded
    When I POST "/api/v1/feeds/eligible" with body:
      """
      {
        "species": "SHEEP",
        "age_months": 24,
        "production_focus": "MILK",
        "lactating": true
      }
      """
    Then the response status should be 200
    And no eligible product is restricted to cattle only

  Scenario: Multi-rule product — Barley raw eligible for cattle and sheep
    When I POST "/api/v1/feeds/eligible" with body:
      """
      {
        "species": "CATTLE",
        "age_months": 24,
        "production_focus": "MEAT",
        "lactating": false
      }
      """
    Then the response status should be 200
    And eligible feed "Barley- raw" is included for dairy cattle
    And eligible feed "Barley- raw" includes eligibility rules in the response
    When I POST "/api/v1/feeds/eligible" with body:
      """
      {
        "species": "SHEEP",
        "age_months": 24,
        "production_focus": "MEAT",
        "lactating": false
      }
      """
    Then the response status should be 200
    And eligible feed "Barley- raw" is included for sheep
    And eligible feed "Barley- raw" has a matching rule with species_scope "SMALL_RUMINANT"

  Scenario: Young cattle — age-restricted products apply
    When I POST "/api/v1/feeds/eligible" with body:
      """
      {
        "species": "CATTLE",
        "age_months": 6,
        "production_focus": "MEAT",
        "lactating": false
      }
      """
    Then the response status should be 200
    And the response JSON at "data.summary.eligible_count" should be at least 15

  Scenario: Goat fattening — small ruminant catalogue
    When I POST "/api/v1/feeds/eligible" with body:
      """
      {
        "species": "GOAT",
        "age_months": 12,
        "production_focus": "MEAT",
        "lactating": false,
        "feed_types": ["FODDER", "CONCENTRATE"]
      }
      """
    Then the response status should be 200
    And the response JSON at "data.summary.eligible_count" should be at least 10

  Scenario: Missing required fields — validation error
    When I POST "/api/v1/feeds/eligible" with body:
      """
      {
        "species": "CATTLE",
        "lactating": true
      }
      """
    Then the response status should be 400

  Scenario: Incomplete species — validation error
    When I POST "/api/v1/feeds/eligible" with body:
      """
      {
        "age_months": 24,
        "production_focus": "MILK",
        "lactating": true
      }
      """
    Then the response status should be 400
