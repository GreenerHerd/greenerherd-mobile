Feature: Notification task preferences
  As a farm owner
  I want to opt in or out of recommended tasks
  So that I only receive relevant notifications

  Background:
    Given the farms API is running

  Scenario: List go-live notification definitions
    Given I am authenticated as farm owner "owner-1"
    When I GET "/api/v1/notification-task-definitions"
    Then the response status should be 200
    And the response JSON at "meta.count" should be greater than 0

  Scenario: Load default preferences for a farm
    Given a farm exists with id "farm-notif"
    And my token includes farm "farm-notif"
    When I GET "/api/v1/farms/farm-notif/notification-preferences"
    Then the response status should be 200
    And the response JSON at "data.items" should not be empty
    And I save "data.items.0.task_definition_id" as "firstDefId"

  Scenario: Disable a notification preference
    Given a farm exists with id "farm-pref"
    And my token includes farm "farm-pref"
    And catalogue definition task_id 9 exists
    When I PUT "/api/v1/farms/farm-pref/notification-preferences" with body:
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
    Then the response status should be 200
    When I GET "/api/v1/farms/farm-pref/notification-preferences"
    Then the response JSON at "data.items" should include disabled task_id 9
