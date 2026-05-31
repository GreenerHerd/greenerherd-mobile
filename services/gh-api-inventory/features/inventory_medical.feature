Feature: Medical inventory
  Operators record medicines with supplier details and track low stock.

  Background:
    Given the inventory API is running

  @positive
  Scenario: List seeded medical inventory
    When I GET inventory "/api/v1/farms/farm-1/inventory/medical"
    Then inventory response status is 200
    And inventory response data path "meta.count" is at least 1

  @positive
  Scenario: Add medicine with supplier and usage estimate
    When I POST inventory "/api/v1/farms/farm-1/inventory/medical" with body:
      """
      {
        "name": "Oxytetracycline",
        "medicine_type": "ANTIBIOTIC",
        "purpose": "Respiratory infections",
        "quantity": 20,
        "unit": "dose",
        "supplier_name": "Vet Supplies KSA",
        "estimated_weekly_usage": 5
      }
      """
    Then inventory response status is 201
    And inventory response data path "quantity" equals 20

  @negative
  Scenario: Reject standard feed without supplier name
    When I POST inventory "/api/v1/farms/farm-1/inventory/feed" with body:
      """
      {
        "name": "Wheat bran",
        "source_type": "STANDARD",
        "quantity_kg": 100,
        "purchased_volume_kg": 200
      }
      """
    Then inventory response status is 400

  @positive
  Scenario: Marketplace feed does not require supplier
    When I POST inventory "/api/v1/farms/farm-1/inventory/feed" with body:
      """
      {
        "name": "Market hay bale",
        "source_type": "MARKETPLACE",
        "marketplace_product_id": "mp-hay-99",
        "quantity_kg": 300,
        "purchased_volume_kg": 300
      }
      """
    Then inventory response status is 201
