Feature: Group feed plans
  As a farm manager
  I want to save and retrieve optimized feed plans per group
  So that morning mixes reflect the latest recommendation

  Background:
    Given the nutrition API is running

  Scenario: Compute group nutrition with feed lines
    When I POST "/api/v1/groups/g1/nutrition" with body:
      """
      {
        "species": "CATTLE",
        "age_months": 48,
        "production_focus": "MILK",
        "lactating": true,
        "months_since_calving": 2,
        "head_count": 22,
        "country_code": "SA",
        "current_intake_ratio": 0.76
      }
      """
    Then the response status should be 200
    And the response JSON at "data.group_id" should be "g1"
    And the response JSON at "data.feed_lines" should not be empty

  Scenario: Recompute group nutrition restricted to an accepted feed
    When I POST "/api/v1/groups/g1/nutrition" with body:
      """
      {
        "species": "CATTLE",
        "age_months": 48,
        "production_focus": "MILK",
        "lactating": true,
        "months_since_calving": 2,
        "head_count": 22,
        "country_code": "SA",
        "current_intake_ratio": 0.76,
        "included_product_numbers": [1014]
      }
      """
    Then the response status should be 200
    And the response JSON at "data.feed_lines" should not be empty
    And the response feed_lines include product number 1014
    And the response feed_lines entry for product number 1014 has name "Steamed Corn Flake"

  Scenario: Save active feed plan for a group
    When I POST "/api/v1/groups/g1/nutrition/plans" with body:
      """
      {
        "species": "CATTLE",
        "age_months": 48,
        "production_focus": "MILK",
        "lactating": true,
        "months_since_calving": 2,
        "head_count": 22,
        "country_code": "SA",
        "current_intake_ratio": 0.76
      }
      """
    Then the response status should be 201
    And the response JSON at "data.plan.group_id" should be "g1"

  Scenario: Load active feed plan after save
    When I POST "/api/v1/groups/g2/nutrition/plans" with body:
      """
      {
        "species": "CATTLE",
        "age_months": 37,
        "production_focus": "BOTH",
        "lactating": false,
        "head_count": 8,
        "country_code": "SA"
      }
      """
    And I GET "/api/v1/groups/g2/nutrition/plans/active"
    Then the response status should be 200
    And the response JSON at "data.group_id" should be "g2"

  Scenario: Return 404 when no active plan exists
    When I GET "/api/v1/groups/unknown-group/nutrition/plans/active"
    Then the response status should be 404
    And the response JSON at "error.code" should be "PLAN_NOT_FOUND"
