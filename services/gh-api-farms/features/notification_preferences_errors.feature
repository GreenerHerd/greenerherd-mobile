Feature: Notification preferences error handling
  As a platform operator
  I want preference APIs to enforce auth and validation
  So that only authorised users can change settings

  Background:
    Given the farms API is running

  Scenario: Reject unauthenticated preference read
    Given a farm exists with id "farm-auth"
    And I have no auth token
    When I GET "/api/v1/farms/farm-auth/notification-preferences"
    Then the response status should be 401
    And the response JSON at "error.code" should be "UNAUTHORIZED"

  Scenario: Reject preference read for farm not in token
    Given a farm exists with id "farm-a"
    And a farm exists with id "farm-b"
    And my token includes farm "farm-a"
    When I GET "/api/v1/farms/farm-b/notification-preferences"
    Then the response status should be 403
    And the response JSON at "error.code" should be "FORBIDDEN"

  Scenario: Reject invalid preference update payload
    Given a farm exists with id "farm-bad"
    And my token includes farm "farm-bad"
    When I PUT "/api/v1/farms/farm-bad/notification-preferences" with body:
      """
      {
        "preferences": [
          {
            "task_definition_id": "not-a-uuid",
            "enabled": false
          }
        ]
      }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"

  Scenario: Reject empty preferences array
    Given a farm exists with id "farm-empty"
    And my token includes farm "farm-empty"
    When I PUT "/api/v1/farms/farm-empty/notification-preferences" with body:
      """
      { "preferences": [] }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"

  Scenario: Reject invalid JWT on preference read
    Given a farm exists with id "farm-jwt"
    And I have an invalid auth token
    When I GET "/api/v1/farms/farm-jwt/notification-preferences"
    Then the response status should be 401
    And the response JSON at "error.code" should be "UNAUTHORIZED"

  Scenario: Reject unauthenticated preference update
    Given a farm exists with id "farm-put-auth"
    And catalogue definition task_id 9 exists
    And I have no auth token
    When I PUT "/api/v1/farms/farm-put-auth/notification-preferences" with body:
      """
      {
        "preferences": [
          {
            "task_definition_id": "{taskDef_9}",
            "enabled": false
          }
        ]
      }
      """
    Then the response status should be 401
    And the response JSON at "error.code" should be "UNAUTHORIZED"

  Scenario: Reject unauthenticated notification definitions list
    Given I have no auth token
    When I GET "/api/v1/notification-task-definitions"
    Then the response status should be 401
    And the response JSON at "error.code" should be "UNAUTHORIZED"

  Scenario: Reject preference update for farm not in token
    Given a farm exists with id "farm-own"
    And a farm exists with id "farm-other"
    And catalogue definition task_id 9 exists
    And my token includes farm "farm-own"
    When I PUT "/api/v1/farms/farm-other/notification-preferences" with body:
      """
      {
        "preferences": [
          {
            "task_definition_id": "{taskDef_9}",
            "enabled": false
          }
        ]
      }
      """
    Then the response status should be 403
    And the response JSON at "error.code" should be "FORBIDDEN"
