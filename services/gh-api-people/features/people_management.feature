Feature: People management
  As a farm admin
  I want to invite and manage users on my farm
  So that the right people can access the right groups

  Background:
    Given the people API is running
    And farm "farm-1" has owner "owner-1"

  Scenario: List farm members includes owner
    Given I am authenticated as OWNER on farm "farm-1"
    When I GET "/api/v1/farms/farm-1/users"
    Then the response status should be 200
    And the response JSON at "meta.total" should be 1

  Scenario: Invite a farm hand
    Given I am authenticated as OWNER on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/users/invite" with body:
      """
      {
        "name": "Ahmad Bilal",
        "email": "ahmad@alfalah.test",
        "farm_role": "FARM_HAND",
        "preferred_lang": "AR",
        "delivery_channel": "EMAIL"
      }
      """
    Then the response status should be 201
    And the response JSON at "data.user.email" should be "ahmad@alfalah.test"
    And the response JSON at "data.farm_user.farm_role" should be "FARM_HAND"
    And the response JSON at "meta.invite_link" should contain "invite="
    And I save "data.user.id" as "ahmadId"

  Scenario: Invite via WhatsApp includes app link
    Given I am authenticated as OWNER on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/users/invite" with body:
      """
      {
        "name": "WhatsApp Hand",
        "phone": "+966501234567",
        "farm_role": "FARM_HAND",
        "delivery_channel": "WHATSAPP"
      }
      """
    Then the response status should be 201
    And the response JSON at "meta.invite_link" should contain "invite="
    And the response JSON at "meta.whatsapp_url" should contain "wa.me"

  Scenario: Farm hand cannot invite users
    Given farm "farm-1" has member "hand-1" with role FARM_HAND
    And I am authenticated as FARM_HAND "hand-1" on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/users/invite" with body:
      """
      {
        "name": "Blocked",
        "email": "blocked@test.com",
        "farm_role": "FARM_HAND",
        "delivery_channel": "EMAIL"
      }
      """
    Then the response status should be 403

  Scenario: Assign group access to farm hand
    Given farm "farm-1" has member "hand-2" with role FARM_HAND
    And I am authenticated as OWNER on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/groups/group-milk/access" with body:
      """
      { "user_id": "hand-2", "can_manage": true }
      """
    Then the response status should be 201
    And the response JSON at "data.can_manage" should be true

  Scenario: Deactivate a member
    Given farm "farm-1" has member "vet-1" with role VET
    And I am authenticated as MANAGER on farm "farm-1"
    When I DELETE "/api/v1/farms/farm-1/users/vet-1"
    Then the response status should be 200
    And the response JSON at "data.farm_user.is_active" should be false

  Scenario: Cannot deactivate farm owner
    Given I am authenticated as OWNER on farm "farm-1"
    When I DELETE "/api/v1/farms/farm-1/users/owner-1"
    Then the response status should be 403
