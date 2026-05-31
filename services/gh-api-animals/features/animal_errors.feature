Feature: Animal API error handling
  As a platform operator
  I want consistent auth, validation, and not-found responses
  So that herd management clients fail safely

  Background:
    Given the animals API is running

  Scenario: Reject unauthenticated animal list
    Given I have no auth token
    When I GET "/api/v1/farms/farm-1/animals"
    Then the response status should be 401
    And the response JSON at "error.code" should be "UNAUTHORIZED"

  Scenario: Reject invalid JWT
    Given I have an invalid auth token
    When I GET "/api/v1/farms/farm-1/animals"
    Then the response status should be 401
    And the response JSON at "error.code" should be "UNAUTHORIZED"

  Scenario: Reject access when farm is not in token
    Given I am authenticated for farm id "farm-other"
    When I GET "/api/v1/farms/farm-1/animals"
    Then the response status should be 403
    And the response JSON at "error.code" should be "FORBIDDEN"

  Scenario: Return 404 for unknown animal
    Given I am authenticated on farm "farm-1"
    When I GET "/api/v1/farms/farm-1/animals/00000000-0000-4000-8000-000000000077"
    Then the response status should be 404
    And the response JSON at "error.code" should be "ANIMAL_NOT_FOUND"

  Scenario: Get animal by id
    Given I am authenticated on farm "farm-1"
    And farm "farm-1" has animal with ear tag "DETAIL1"
    And I save "lastAnimalId" from last created animal
    When I GET "/api/v1/farms/farm-1/animals/{lastAnimalId}"
    Then the response status should be 200
    And the response JSON at "data.ear_tag" should be "DETAIL1"

  Scenario: Reject create animal with empty breed
    Given I am authenticated on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/animals" with body:
      """
      {
        "species": "SHEEP",
        "sex": "FEMALE",
        "breed": "",
        "ear_tag": "E001"
      }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"

  Scenario: Reject invalid species enum
    Given I am authenticated on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/animals" with body:
      """
      {
        "species": "CAMEL",
        "sex": "FEMALE",
        "breed": "Test",
        "ear_tag": "E002"
      }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"

  Scenario: Reject bulk group with zero count
    Given I am authenticated on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/groups/bulk" with body:
      """
      {
        "species": "GOAT",
        "breed": "Aardi",
        "sex": "FEMALE",
        "age_range": "1_2Y",
        "count": 0,
        "name": "Empty Group",
        "purpose": "MAINTENANCE"
      }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"

  Scenario: Reject malformed JSON on create animal
    Given I am authenticated on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/animals" with malformed JSON
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"

  Scenario: Reject unknown breed name
    Given I am authenticated on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/animals" with body:
      """
      {
        "species": "CATTLE",
        "sex": "FEMALE",
        "breed": "NotARealBreed",
        "ear_tag": "UNK001"
      }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "UNKNOWN_BREED"

  Scenario: Reject breed_id that does not match species
    Given cattle breed "Holstein" is saved as "holsteinBreedId"
    And I am authenticated on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/animals" with body:
      """
      {
        "species": "SHEEP",
        "sex": "FEMALE",
        "breed_id": "{holsteinBreedId}",
        "ear_tag": "MIX001"
      }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "UNKNOWN_BREED"

  Scenario: Reject create animal without breed or breed_id
    Given I am authenticated on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/animals" with body:
      """
      {
        "species": "GOAT",
        "sex": "FEMALE",
        "ear_tag": "NB001"
      }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"

  Scenario: Reject bulk group with unknown breed
    Given I am authenticated on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/groups/bulk" with body:
      """
      {
        "species": "GOAT",
        "breed": "ImaginaryGoat",
        "sex": "FEMALE",
        "age_range": "1_2Y",
        "count": 2,
        "name": "Bad Breed Group",
        "purpose": "MAINTENANCE"
      }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "UNKNOWN_BREED"
