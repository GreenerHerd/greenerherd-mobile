Feature: Farm finance

  Background:
    Given the finance API is running
    And my token includes farm "farm-1"

  Scenario: Get finance summary
    When I GET "/api/v1/farms/farm-1/finance/summary"
    Then the response status should be 200
    And the response JSON at "data.income_3mo" should be greater than 0

  Scenario: Record a purchase
    When I POST "/api/v1/farms/farm-1/finance/purchases" with body:
      """
      { "purchase_date": "2026-05-10", "total_amount": 8000, "supplier": "Test Supplier" }
      """
    Then the response status should be 201
    And the response JSON at "data.total_amount" should be 8000

  Scenario: Record a sale
    When I POST "/api/v1/farms/farm-1/finance/sales" with body:
      """
      { "sale_date": "2026-05-11", "total_amount": 4500, "animal_ids": ["a1"] }
      """
    Then the response status should be 201
