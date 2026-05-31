Feature: People API error handling
  As a platform operator
  I want consistent auth, validation, conflict, and not-found responses
  So that farm admins can trust API error contracts

  Background:
    Given the people API is running

  Scenario: Reject unauthenticated list users
    Given farm "farm-1" has owner "owner-1"
    And I have no auth token
    When I GET "/api/v1/farms/farm-1/users"
    Then the response status should be 401
    And the response JSON at "error.code" should be "UNAUTHORIZED"

  Scenario: Reject invalid JWT
    Given farm "farm-1" has owner "owner-1"
    And I have an invalid auth token
    When I GET "/api/v1/farms/farm-1/users"
    Then the response status should be 401
    And the response JSON at "error.code" should be "UNAUTHORIZED"

  Scenario: Reject access when farm is not in token
    Given farm "farm-1" has owner "owner-1"
    And I am authenticated for farm id "farm-other"
    When I GET "/api/v1/farms/farm-1/users"
    Then the response status should be 403
    And the response JSON at "error.code" should be "FORBIDDEN"

  Scenario: Duplicate invite returns conflict
    Given farm "farm-1" has owner "owner-1"
    And farm "farm-1" has invited user with email "dup@alfalah.test"
    And I am authenticated as OWNER on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/users/invite" with body:
      """
      {
        "name": "Duplicate User",
        "email": "dup@alfalah.test",
        "farm_role": "FARM_HAND",
        "delivery_channel": "EMAIL"
      }
      """
    Then the response status should be 409
    And the response JSON at "error.code" should be "USER_ALREADY_ON_FARM"

  Scenario: Reject invalid email on invite
    Given farm "farm-1" has owner "owner-1"
    And I am authenticated as OWNER on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/users/invite" with body:
      """
      {
        "name": "Bad Email",
        "email": "not-an-email",
        "farm_role": "FARM_HAND",
        "delivery_channel": "EMAIL"
      }
      """
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"

  Scenario: Return 404 when updating unknown member
    Given farm "farm-1" has owner "owner-1"
    And I am authenticated as OWNER on farm "farm-1"
    When I PATCH "/api/v1/farms/farm-1/users/00000000-0000-4000-8000-000000000099" with body:
      """
      { "farm_role": "MANAGER" }
      """
    Then the response status should be 404
    And the response JSON at "error.code" should be "MEMBER_NOT_FOUND"

  Scenario: Return 404 when assigning group access to non-member
    Given farm "farm-1" has owner "owner-1"
    And I am authenticated as OWNER on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/groups/group-milk/access" with body:
      """
      { "user_id": "00000000-0000-4000-8000-000000000088", "can_manage": true }
      """
    Then the response status should be 404
    And the response JSON at "error.code" should be "MEMBER_NOT_FOUND"

  Scenario: Promote farm hand to manager via PATCH
    Given farm "farm-1" has owner "owner-1"
    And farm "farm-1" has member "hand-3" with role FARM_HAND
    And I am authenticated as OWNER on farm "farm-1"
    When I PATCH "/api/v1/farms/farm-1/users/hand-3" with body:
      """
      { "farm_role": "MANAGER" }
      """
    Then the response status should be 200
    And the response JSON at "data.farm_user.farm_role" should be "MANAGER"

  Scenario: Reject malformed JSON on invite
    Given farm "farm-1" has owner "owner-1"
    And I am authenticated as OWNER on farm "farm-1"
    When I POST "/api/v1/farms/farm-1/users/invite" with malformed JSON
    Then the response status should be 400
    And the response JSON at "error.code" should be "VALIDATION_ERROR"
