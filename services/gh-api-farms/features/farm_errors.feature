Feature: Farm API error handling
  As a platform operator
  I want consistent auth, validation, and not-found responses
  So that clients can handle failures predictably

  Background:
    Given the farms API is running

  Scenario: Reject invalid JWT
    Given I have an invalid auth token
    When I GET "/api/v1/farms/any-id"
    Then the response status should be 401
    And the response JSON at "error.code" should be "UNAUTHORIZED"

  Scenario: Reject missing auth on create farm
    Given I have no auth token
    When I POST "/api/v1/farms" with body:
      """
      {
        "name": "No Auth Farm",
        "country": "SA",
        "housing_type": "PASTURE",
        "preferred_currency": "SAR",
        "preferred_lang": "EN"
      }
      """
    Then the response status should be 401
    And the response JSON at "error.code" should be "UNAUTHORIZED"

  Scenario: Reject access to farm not in token
    Given a farm exists with id "farm-locked"
    And a farm exists with id "farm-token"
    And my token includes farm "farm-token"
    When I GET "/api/v1/farms/farm-locked"
    Then the response status should be 403
    And the response JSON at "error.code" should be "FORBIDDEN"

  Scenario: Return 404 for unknown farm
    Given I am authenticated for farm id "00000000-0000-4000-8000-000000000001"
    When I GET "/api/v1/farms/00000000-0000-4000-8000-000000000001"
    Then the response status should be 404
    And the response JSON at "error.code" should be "FARM_NOT_FOUND"

  Scenario: Reject create farm with missing name
    Given I am authenticated as farm owner "owner-1"
    When I POST "/api/v1/farms" with body:
      """
      {
        "country": "SA",
        "housing_type": "PASTURE",
        "preferred_currency": "SAR",
        "preferred_lang": "EN"
      }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"

  Scenario: Reject invalid species enum
    Given a farm exists with id "farm-val"
    And my token includes farm "farm-val"
    When I POST "/api/v1/farms/farm-val/species" with body:
      """
      { "species": "CAMEL", "purpose": "MILK" }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"

  Scenario: Reject malformed JSON body
    Given I am authenticated as farm owner "owner-1"
    When I POST "/api/v1/farms" with malformed JSON
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"

  Scenario: Update farm profile via PATCH
    Given a farm exists with id "farm-patch"
    And my token includes farm "farm-patch"
    When I PATCH "/api/v1/farms/farm-patch" with body:
      """
      { "name": "Updated Farm Name" }
      """
    Then the response status should be 200
    And the response JSON at "data.name" should be "Updated Farm Name"

  Scenario: Dashboard returns 404 for missing farm
    Given I am authenticated for farm id "00000000-0000-4000-8000-000000000002"
    When I GET "/api/v1/farms/00000000-0000-4000-8000-000000000002/dashboard"
    Then the response status should be 404
    And the response JSON at "error.code" should be "FARM_NOT_FOUND"
