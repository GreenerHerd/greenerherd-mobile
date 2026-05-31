Feature: Meal plans from inventory
  Operators define meal batches from on-hand feed and assign ingredients by weight.

  Background:
    Given the inventory API is running

  @positive
  Scenario: List seeded meal with ingredients
    When I GET inventory "/api/v1/farms/farm-1/meals"
    Then inventory response status is 200
    And inventory response data path "meta.count" is at least 1
    And inventory first meal has at least 2 ingredients

  @positive
  Scenario: Create meal and set ingredients from feed stock
    When I POST inventory "/api/v1/farms/farm-1/meals" with body:
      """
      { "name": "Evening mix", "description": "Dry cows" }
      """
    Then inventory response status is 201
    When I PUT inventory meal ingredients for first meal from feed list
    Then inventory response status is 200
    And inventory response data path "total_kg_per_batch" equals 85
