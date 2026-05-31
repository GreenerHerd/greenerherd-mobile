Feature: Feed recommendation optimizer
  As a nutrition service
  I need a least-cost feed mix that meets group requirements
  So that farmers get actionable daily ration plans

  Background:
    Given the nutrition API is running

  Scenario: Recommend feed plan for lactating dairy cattle in Saudi Arabia
    When I POST "/api/v1/groups/test-group/nutrition/recommend" with body:
      """
      {
        "species": "CATTLE",
        "age_months": 48,
        "production_focus": "MILK",
        "lactating": true,
        "months_since_calving": 2,
        "head_count": 10,
        "country_code": "SA"
      }
      """
    Then the response status should be 200
    And the response JSON at "data.optimizer_pass" should be "complete"
    And the response JSON at "data.profile_code" should be "CATTLE_DAIRY_COW_EARLY"
    And the response JSON at "data.recommendation.cost_per_day" should be greater than 0
    And the response JSON at "data.recommendation.solution" should not be empty
    And the recommendation meets optimizer nutrient thresholds
    And the recommendation meets cattle feed-type DM limits when applicable

  Scenario: Recommend feed plan for goats
    When I POST "/api/v1/groups/goat-herd/nutrition/recommend" with body:
      """
      {
        "species": "GOAT",
        "age_months": 24,
        "production_focus": "MILK",
        "lactating": true,
        "head_count": 5,
        "country_code": "SA"
      }
      """
    Then the response status should be 200
    And the response JSON at "data.optimizer_pass" should be "complete"
    And the response JSON at "data.profile_code" should be "GOAT_SMALL_RUMINANT_LACTATING"
    And the recommendation meets optimizer nutrient thresholds
