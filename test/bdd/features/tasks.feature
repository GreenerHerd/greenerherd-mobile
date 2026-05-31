Feature: Farm tasks (scheduler integration)
  As a farm operator
  I want to see and complete notification-driven tasks
  So that reminders from nutrition and inventory events are actionable

  @positive
  Scenario: Hybrid repository lists API tasks with due labels
    Given a tasks gateway returns a pending vaccination task
    When I list tasks from the hybrid repository
    Then task "Clostridium Vaccination Due" is included
    And the task is marked overdue

  @positive
  Scenario: Completing a task calls the tasks API
    Given a tasks gateway returns a pending feed task
    When I complete task "Buy more Alfalfa hay"
    Then the gateway records task "Buy more Alfalfa hay" as completed

  @positive
  Scenario: Manual tasks remain available when API is empty
    Given the tasks gateway returns no rows
    And a manual task exists locally
    When I list tasks from the hybrid repository
    Then task "Check water troughs" is included

  @positive
  Scenario: Tasks screen shows scheduler-generated title
    Given a tasks gateway returns a pending vaccination task
    When the tasks screen is open
    Then I see task title "Clostridium Vaccination Due"
