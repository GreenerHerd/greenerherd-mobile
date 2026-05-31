Feature: Notification scheduler and farm tasks
  As a farm operator
  I want automatic tasks created from notification definitions
  So that reminders appear when triggers fire

  Background:
    Given the tasks API is running
    And I am authenticated for farm "farm-1"

  Scenario: Scheduler creates tasks on nightly sweep
    When I POST "/api/v1/farms/farm-1/scheduler/run" with body:
      """
      {}
      """
    Then the response status should be 200
    And the response JSON at "data.tasks_created" should be greater than 0

  Scenario: Product accepted event creates feed update tasks
    When I emit nutrition product accepted for group "g1" on farm "farm-1"
    Then the response status should be 200
    And the response JSON at "data.tasks_created" should be at least 1
    And created tasks should include an accept-product task

  Scenario: Inventory below threshold event creates low-stock task
    When I emit inventory below threshold on farm "farm-1"
    Then the response status should be 200
    And the response JSON at "data.tasks_created" should be at least 1
    And created tasks should include a low inventory task

  Scenario: List generated farm tasks
    When I POST "/api/v1/farms/farm-1/scheduler/run" with body:
      """
      {}
      """
    And I GET "/api/v1/farms/farm-1/tasks"
    Then the response status should be 200
    And the response JSON at "meta.total" should be greater than 0

  Scenario: Dismiss a farm task
    When I POST "/api/v1/farms/farm-1/scheduler/run" with body:
      """
      {}
      """
    And I GET "/api/v1/farms/farm-1/tasks"
    And I save "data.0.id" as "taskId"
    When I POST "/api/v1/tasks/{taskId}/dismiss" with body:
      """
      {}
      """
    Then the response status should be 200
    And the response JSON at "data.status" should be "DISMISSED"

  Scenario: Complete a farm task
    When I POST "/api/v1/farms/farm-1/scheduler/run" with body:
      """
      {}
      """
    And I GET "/api/v1/farms/farm-1/tasks"
    And I save "data.0.id" as "taskId"
    When I POST "/api/v1/tasks/{taskId}/complete" with body:
      """
      {}
      """
    Then the response status should be 200
    And the response JSON at "data.status" should be "COMPLETE"

  Scenario: Disabled preference blocks low inventory tasks
    Given user notification preferences disable low inventory for farm "farm-1"
    When I run the notification scheduler for farm "farm-1"
    Then created tasks should not include low inventory titles
