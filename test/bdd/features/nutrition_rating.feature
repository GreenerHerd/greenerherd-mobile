Feature: Nutrition rating display
  As a user reviewing intake
  I want nutrition gaps shown with traffic-light bars
  So that I can spot energy or dry matter shortfalls

  @positive
  Scenario: Milking group gap shows energy gap badge
    Given nutrition data for group "g1"
    Then the gap badge is "Energy gap"
    And dry matter reads "194 / 202 kg"

  @negative
  Scenario: On-target group shows no gap badge
    Given nutrition data for group "g2"
    Then the gap badge is not "Energy gap"

  @positive
  Scenario: Animal birth does not duplicate lactating tag
    Given a pregnant lactating cow
    When a live birth is recorded
    Then lactating appears only once in tags
