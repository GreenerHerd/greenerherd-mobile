Feature: Notification scheduler error handling
  As a platform operator
  I want auth and validation failures handled consistently
  So that clients and cron jobs fail safely

  Background:
    Given the tasks API is running

  Scenario: Reject unauthenticated scheduler run
    Given I have no auth token
    When I POST "/api/v1/farms/farm-1/scheduler/run" with body:
      """
      {}
      """
    Then the response status should be 401
    And the response JSON at "error.code" should be "UNAUTHORIZED"

  Scenario: Reject scheduler for farm not in token
    Given I am authenticated for farm "farm-allowed"
    When I POST "/api/v1/farms/farm-denied/scheduler/run" with body:
      """
      {}
      """
    Then the response status should be 403
    And the response JSON at "error.code" should be "FORBIDDEN"

  Scenario: Reject invalid domain event type body
    Given I am authenticated for farm "farm-1"
    When I POST "/api/v1/farms/farm-1/events" with body:
      """
      { "type": "" }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"

  Scenario: Internal scheduler rejects wrong secret
    When I POST "/internal/farms/farm-1/scheduler/run" with wrong scheduler secret
    Then the response status should be 403
    And the response JSON at "error.code" should be "FORBIDDEN"

  Scenario: Internal scheduler accepts valid secret
    When I POST "/internal/farms/farm-1/scheduler/run" with scheduler secret "bdd-scheduler-secret" and body:
      """
      {}
      """
    Then the response status should be 200
    And the response JSON at "data.tasks_created" should be at least 0

  Scenario: Return 404 when completing unknown task
    Given I am authenticated for farm "farm-1"
    When I POST "/api/v1/tasks/00000000-0000-4000-8000-000000009999/complete" with body:
      """
      {}
      """
    Then the response status should be 404
    And the response JSON at "error.code" should be "TASK_NOT_FOUND"

  Scenario: Return 404 when dismissing unknown task
    Given I am authenticated for farm "farm-1"
    When I POST "/api/v1/tasks/00000000-0000-4000-8000-000000009999/dismiss" with body:
      """
      {}
      """
    Then the response status should be 404
    And the response JSON at "error.code" should be "TASK_NOT_FOUND"

  Scenario: Return 404 when fetching unknown task
    Given I am authenticated for farm "farm-1"
    When I GET "/api/v1/tasks/00000000-0000-4000-8000-000000009999"
    Then the response status should be 404
    And the response JSON at "error.code" should be "TASK_NOT_FOUND"

  Scenario: Reject unauthenticated task list
    Given I have no auth token
    When I GET "/api/v1/farms/farm-1/tasks"
    Then the response status should be 401
    And the response JSON at "error.code" should be "UNAUTHORIZED"

  Scenario: Reject invalid JWT on scheduler run
    Given I have an invalid auth token
    When I POST "/api/v1/farms/farm-1/scheduler/run" with body:
      """
      {}
      """
    Then the response status should be 401
    And the response JSON at "error.code" should be "UNAUTHORIZED"

  Scenario: Reject unknown domain event type
    Given I am authenticated for farm "farm-1"
    When I POST "/api/v1/farms/farm-1/events" with body:
      """
      { "type": "not.a.real.event" }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"

  Scenario: Second scheduler run does not duplicate tasks
    Given I am authenticated for farm "farm-1"
    When I POST "/api/v1/farms/farm-1/scheduler/run" with body:
      """
      {}
      """
    And I GET "/api/v1/farms/farm-1/tasks"
    And I save "meta.total" as "firstTotal"
    When I POST "/api/v1/farms/farm-1/scheduler/run" with body:
      """
      {}
      """
    Then the response status should be 200
    And the response JSON at "data.tasks_created" should be 0
    When I GET "/api/v1/farms/farm-1/tasks"
    Then the response JSON at "meta.total" should equal saved "firstTotal"
