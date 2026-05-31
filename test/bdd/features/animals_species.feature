Feature: Animals list species filter
  As a user on the Animals tab
  I want to filter animals by species
  So that I can focus on one herd type at a time

  @positive
  Scenario: Animals screen shows species filter chips
    When the animals list is shown
    Then they see "All species" and "Cattle" chips

  @positive
  Scenario: Animals list shows seeded cattle
    When the animals list is shown
    Then they see cattle records such as Mona

  @positive
  Scenario: Selecting cattle filters out other species
    When the user selects the cattle chip
    Then sheep records are hidden

  @negative
  Scenario: Invalid species label is not shown
    When the animals list is shown
    Then "Marsupials" is not shown
