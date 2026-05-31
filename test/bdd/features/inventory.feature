Feature: Inventory management
  As a farm operator
  I want to track feed and medicines, see low-stock warnings, and manage stock levels
  So that I can reorder before running out

  @positive
  Scenario: Feed inventory lists seeded products with low-stock state
    Given local inventory is loaded
    When I list feed inventory
    Then feed item "Alfalfa hay (mid-bloom)" is marked low stock
    And feed item "Barley concentrate" is marked low stock

  @positive
  Scenario: Medical inventory lists seeded medicines
    Given local inventory is loaded
    When I list medical inventory
    Then medical inventory includes "Penicillin"

  @positive
  Scenario: Recording feeding deducts stock and flags low items
    Given local inventory is loaded
    When I record feeding for group "g1" with meal "Morning mix" and 85 kg
    Then feed item "Alfalfa hay (mid-bloom)" quantity is below 120 kg
    And low stock feed count is at least 1

  @negative
  Scenario: Custom feed without nutrition is rejected in the add feed form
    Given the add feed screen is open
    When I select custom feed source and save without nutrition
    Then I see validation "Add at least one nutritional value"

  @positive
  Scenario: Inventory screen shows feed tab and low-stock banner
    Given the inventory screen is open
    Then I see feed product "Alfalfa hay (mid-bloom)"
    And I see low stock banner text
