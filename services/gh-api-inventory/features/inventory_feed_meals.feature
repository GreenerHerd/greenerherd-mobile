Feature: Farm inventory, meals, and feeding
  Operators track feed and medicines, build meal plans, and deduct stock when feeding groups.

  Background:
    Given the inventory API is running

  @positive
  Scenario: List seeded feed inventory with low-stock flags
    When I GET inventory "/api/v1/farms/farm-1/inventory/feed"
    Then inventory response status is 200
    And inventory response data path "meta.count" is at least 2

  Scenario: Reject custom feed without nutrition
    When I POST inventory "/api/v1/farms/farm-1/inventory/feed" with body:
      """
      {
        "name": "Mystery mix",
        "source_type": "CUSTOM",
        "quantity_kg": 50,
        "purchased_volume_kg": 100,
        "supplier_name": "Local mill"
      }
      """
    Then inventory response status is 400

  @positive
  Scenario: Add custom feed with nutrition and supplier
    When I POST inventory "/api/v1/farms/farm-1/inventory/feed" with body:
      """
      {
        "name": "Farm blend",
        "source_type": "CUSTOM",
        "quantity_kg": 200,
        "purchased_volume_kg": 500,
        "supplier_name": "Local mill",
        "custom_nutrition": {
          "feed_type": "CONCENTRATE",
          "dry_matter_percent": 88,
          "crude_protein_percent": 16
        }
      }
      """
    Then inventory response status is 201

  @positive
  Scenario: Low stock summary after feeding deducts inventory
    When I POST inventory feeding with meal and weight 85
    Then inventory response status is 201
    When I GET inventory "/api/v1/farms/farm-1/inventory/low-stock"
    Then inventory response status is 200
    And inventory low stock feed count is at least 1
