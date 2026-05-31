Feature: Animal and group management
  As a farm manager
  I want to register animals individually or in bulk groups
  So that I can track my herd during and after onboarding

  Background:
    Given the animals API is running
    And I am authenticated on farm "farm-1"

  Scenario: Create an individual animal (onboarding path A)
    When I POST "/api/v1/farms/farm-1/animals" with body:
      """
      {
        "species": "CATTLE",
        "sex": "FEMALE",
        "breed": "Holstein",
        "ear_tag": "0421",
        "name": "Bessie",
        "tags": ["PREGNANT", "LACTATING"]
      }
      """
    Then the response status should be 201
    And the response JSON at "data.ear_tag" should be "0421"
    And the response JSON at "data.cull_flagged" should be false
    And the response JSON at "data.breed" should be "Holstein"
    And the response JSON at "data.breed_ref.name_en" should be "Holstein"
    And the response JSON at "data.breed_ref.species" should be "CATTLE"
    And I save "data.id" as "bessieId"
    And I save "data.breed_id" as "holsteinBreedId"

  Scenario: Create animal using breed_id
    Given cattle breed "Holstein" is saved as "holsteinBreedId"
    When I POST "/api/v1/farms/farm-1/animals" with body:
      """
      {
        "species": "CATTLE",
        "sex": "FEMALE",
        "breed_id": "{holsteinBreedId}",
        "ear_tag": "H0422",
        "name": "Daisy"
      }
      """
    Then the response status should be 201
    And the response JSON at "data.breed" should be "Holstein"
    And the response JSON at "data.breed_ref.primary_purpose" should be "Dairy"

  Scenario: Duplicate ear tag is rejected
    Given farm "farm-1" has animal with ear tag "0999"
    When I POST "/api/v1/farms/farm-1/animals" with body:
      """
      {
        "species": "CATTLE",
        "sex": "FEMALE",
        "breed": "Jersey",
        "ear_tag": "0999"
      }
      """
    Then the response status should be 409
    And the response JSON at "error.code" should be "EAR_TAG_EXISTS"

  Scenario: Create a group with bulk animals (onboarding path B)
    When I POST "/api/v1/farms/farm-1/groups/bulk" with body:
      """
      {
        "species": "GOAT",
        "breed": "Aardi",
        "sex": "FEMALE",
        "age_range": "1_2Y",
        "count": 3,
        "name": "Pregnant Does",
        "purpose": "PREGNANT"
      }
      """
    Then the response status should be 201
    And the response JSON at "meta.animals_created" should be 3
    When I GET "/api/v1/farms/farm-1/animals?species=GOAT"
    Then the response status should be 200
    And the response JSON at "meta.total" should be 3

  Scenario: Cull flag then sell lifecycle
    Given farm "farm-1" has animal with ear tag "S012"
    And I save "lastAnimalId" from last created animal
    When I POST "/api/v1/farms/farm-1/animals/{lastAnimalId}/cull"
    Then the response status should be 200
    And the response JSON at "data.cull_flagged" should be true
    When I POST "/api/v1/farms/farm-1/animals/{lastAnimalId}/sell"
    Then the response status should be 200
    And the response JSON at "data.status" should be "SOLD"

  Scenario: Cannot sell without cull flag
    Given farm "farm-1" has animal with ear tag "S099"
    And I save "sellTestId" from last created animal
    When I POST "/api/v1/farms/farm-1/animals/{sellTestId}/sell"
    Then the response status should be 400

  Scenario: Filter animals by status tag
    Given farm "farm-1" has animal with ear tag "SICK1" and tags SICK
    When I GET "/api/v1/farms/farm-1/animals?tag=SICK"
    Then the response status should be 200
    And the response JSON at "meta.total" should be 1
