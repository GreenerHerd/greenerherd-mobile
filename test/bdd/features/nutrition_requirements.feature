Feature: Nutrition requirements from Livestock Nutrition Requirements masterfile
  Validates profile resolution and nutrient targets for dairy, beef, and small
  ruminant livestock variations. Data is extracted from the xlsx masterfile into
  assets/data/nutrition_requirements.json; scenarios mirror gh-shared BDD matrix.

  Scenario: Masterfile catalog loads from xlsx export
    Given the nutrition requirements catalog is loaded
    Then dairy, beef, and small ruminant profiles are present

  Scenario: Every dairy masterfile stage exists in catalog with DMI
    Given the nutrition requirements catalog is loaded
    Then each dairy life stage profile matches spreadsheet DMI values

  Scenario Outline: Resolve profile for livestock variation <scenario_id>
    Given the nutrition requirements catalog is loaded
    When I resolve nutrition for scenario "<scenario_id>"
    Then the profile code should match the masterfile expectation
    And per-animal dry matter requirements should be positive
