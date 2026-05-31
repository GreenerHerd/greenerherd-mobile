Feature: Feed stock limits and meal-plan stock checks
  Negative on-hand quantities are not allowed; feeding cannot drive stock below zero.
  Meal ingredient saves return warnings when stock is low or insufficient for one batch.

  Background:
    Given the inventory API is running

  @negative
  Scenario: Reject negative quantity when adding feed
    When I POST inventory "/api/v1/farms/farm-1/inventory/feed" with body:
      """
      {
        "name": "Bad batch",
        "source_type": "CUSTOM",
        "quantity_kg": -25,
        "purchased_volume_kg": 100,
        "supplier_name": "Local mill",
        "custom_nutrition": {
          "feed_type": "FODDER",
          "dry_matter_percent": 90
        }
      }
      """
    Then inventory response status is 400

  @positive
  Scenario: Feeding more than on-hand stock clamps quantity to zero
    When I GET inventory "/api/v1/farms/farm-1/inventory/feed"
    Then inventory response status is 200
    When I POST inventory feeding with meal and weight 500
    Then inventory response status is 201
    When I GET inventory "/api/v1/farms/farm-1/inventory/feed"
    Then inventory response status is 200
    And inventory feed item "Alfalfa hay (mid-bloom)" quantity kg is 0

  @positive
  Scenario: Meal ingredients return low-stock warnings
    When I GET inventory "/api/v1/farms/farm-1/meals"
    Then inventory response status is 200
    When I PUT inventory meal ingredients for first meal from feed list
    Then inventory response status is 200
    And inventory meal has low stock warning

  @negative
  Scenario: Meal ingredients flag insufficient stock for one batch
    When I POST inventory "/api/v1/farms/farm-1/meals" with body:
      """
      { "name": "Heavy batch", "description": "Test" }
      """
    Then inventory response status is 201
    When I PUT inventory meal ingredients exceeding stock for saved meal
    Then inventory response status is 200
    And inventory meal has insufficient stock warning
