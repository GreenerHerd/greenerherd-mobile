Feature: Meal plans from inventory
  As a farm operator
  I want to combine feed products into meal batches
  So that I can record group feeding consistently

  @positive
  Scenario: Seeded morning mix lists ingredients and batch weight
    Given local inventory is loaded
    When I list meal plans
    Then meal "Morning mix" has total batch weight 85 kg
    And meal "Morning mix" includes ingredient "Alfalfa hay (mid-bloom)"

  @positive
  Scenario: New meal can be created with ingredients
    Given local inventory is loaded
    When I create meal "Test ration" with alfalfa 40 kg and barley 15 kg
    Then meal "Test ration" has total batch weight 55 kg

  @positive
  Scenario: Meal plans screen lists seeded meal
    Given the meal plans screen is open
    Then I see meal plan "Morning mix"

  @positive
  Scenario: Saving meal ingredients warns when stock is low
    Given local inventory is loaded
    When I save meal ingredients with alfalfa 200 kg per batch
    Then meal stock warnings include low stock for alfalfa

  @negative
  Scenario: Negative feed quantity is stored as zero
    Given local inventory is loaded
    When I add feed "Empty bag" with quantity -40 kg
    Then feed item "Empty bag" on hand quantity is 0 kg

  @negative
  Scenario: Feeding beyond on-hand stock clamps to zero
    Given local inventory is loaded
    When I record an oversized feeding for group "g1"
    Then feed item "Alfalfa hay (mid-bloom)" on hand quantity is 0 kg
