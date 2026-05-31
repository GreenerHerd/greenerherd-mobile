Feature: Nutrition recommendation matrix (masterfile + legacy harness)
  Aligns with product-suggestions/tests/nutrition-service-test.js scenarios and
  Livestock Nutrition Requirements.xlsx (dairy stages, beef, small ruminant).
  Validates profile selection, HTTP status, and nutrient / feed-type thresholds.

  Background:
    Given the nutrition API is running

  Scenario Outline: Recommend — <scenario_id>
    When I request nutrition recommend for scenario "<scenario_id>"
    Then the nutrition matrix result should match expectations

    Examples: Legacy product-suggestions scenarios
      | scenario_id              |
      | legacy_dairy_lactating   |
      | legacy_dairy_pregnant    |
      | legacy_beef_calf         |
      | legacy_lactating_ewe     |
      | legacy_breeding_ram      |
      | legacy_lactating_doe     |

    Examples: Dairy masterfile life stages
      | scenario_id              |
      | dairy_dry_far_off        |
      | dairy_close_up           |
      | dairy_fresh              |
      | dairy_mid_lactation      |
      | dairy_late_lactation     |
      | dairy_heifer_6mo         |
      | dairy_heifer_12mo        |
      | dairy_heifer_18mo        |
      | dairy_heifer_24mo_close  |

    Examples: Beef production (representative)
      | scenario_id              |
      | beef_early_lactation     |
      | beef_mid_gestation       |
      | beef_maintenance         |

    Examples: Small ruminant masterfile
      | scenario_id              |
      | goat_maintenance         |
      | goat_pregnant            |
      | goat_fattening           |
      | sheep_pregnant           |
      | sheep_fattening          |

    Examples: Group scaling
      | scenario_id              |
      | group_10_dairy           |
      | group_50_dairy           |
