Feature: Feed catalogue structure (products with eligibility rules)
  The standard catalogue is one row per product; species and limits live on
  feed_product_eligibility_rules (multiple rules per product when needed).

  Background:
    Given the nutrition API is running
    And the feed catalog has at least 60 products with eligibility rules

  Scenario: Health endpoint reports loaded catalogue size
    When I GET "/api/v1/reference/feeds/health"
    Then the response status should be 200
    And the response JSON at "data.loaded" should be at least 60

  Scenario: List reference feeds returns products with eligibility_rules
    When I GET "/api/v1/reference/feeds"
    Then the response status should be 200
    And each reference feed product has at least one eligibility rule
    And reference feed "Barley" is listed with species scope "ALL"

  Scenario: Filter reference feeds by species uses eligibility rules
    When I GET "/api/v1/reference/feeds?species=SHEEP"
    Then the response status should be 200
    And the response JSON at "data" should not be empty
    And each reference feed product has a rule for species "SHEEP"

  Scenario: Get product by product_number includes eligibility_rules
    Given feed product number for "Steamed Corn Flake" is saved as steamedCornNum
    When I GET "/api/v1/reference/feeds/{steamedCornNum}"
    Then the response status should be 200
    And the response product has at least 1 eligibility rule
    And the response product has a rule with species_scope "CATTLE"

  Scenario: Multi-rule product is returned once with multiple rules
    When I GET "/api/v1/reference/feeds"
    Then reference feed "Barley- raw" has exactly 2 eligibility rules
    And reference feed "Barley- raw" has rules for species scopes "CATTLE" and "SMALL_RUMINANT"
