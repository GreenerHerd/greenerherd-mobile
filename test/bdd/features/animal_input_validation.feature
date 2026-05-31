Feature: Animal input validation
  As a farm manager
  I want invalid animal data rejected before save
  So that herd records stay accurate

  Background:
    Given validation uses reference date 2026-05-17

  # --- Tag ---

  @positive
  Scenario: Valid tag passes validation
    When tag "0999" is validated with no duplicates
    Then validation succeeds

  @negative
  Scenario: Empty tag is rejected
    When tag "   " is validated
    Then validation fails with "Tag number is required"

  @negative
  Scenario: Duplicate tag is rejected
    When tag "0438" is validated against existing tags
    Then validation fails with code tagDuplicate

  # --- Weight ---

  @positive
  Scenario: Valid cattle weight passes
    When weight "412" kg is validated for cattle
    Then validation succeeds

  @positive
  Scenario: Small calf weight passes
    When weight "45" kg is validated for cattle
    Then validation succeeds

  @negative
  Scenario: Zero weight is rejected
    When weight "0" kg is validated for cattle
    Then validation fails with "greater than zero"

  @negative
  Scenario: Negative weight is rejected
    When weight "-12" kg is validated for cattle
    Then validation fails with code weightNonPositive

  @negative
  Scenario: Non-numeric weight is rejected
    When weight "heavy" is validated for cattle
    Then validation fails with code weightNotANumber

  @negative
  Scenario: Missing weight is rejected
    When weight "" is validated for cattle
    Then validation fails with code weightMissing

  @negative
  Scenario: Weight above cattle maximum is rejected
    When weight "2000" kg is validated for cattle
    Then validation fails with code weightExceedsSpeciesMax

  @negative
  Scenario: Weight above goat maximum is rejected
    When weight "250" kg is validated for goat
    Then validation fails with code weightExceedsSpeciesMax

  # --- Birth date ---

  @positive
  Scenario: Birth date in the past passes
    When birth date 2020-03-15 is validated for cattle
    Then validation succeeds

  @positive
  Scenario: Birth date today passes
    When birth date 2026-05-17 is validated for cattle
    Then validation succeeds

  @negative
  Scenario: Future birth date is rejected
    When birth date 2026-06-01 is validated for cattle
    Then validation fails with "cannot be in the future"

  @negative
  Scenario: Implausibly old cattle birth date is rejected
    When birth date 1990-01-01 is validated for cattle
    Then validation fails with code dobTooOld

  @negative
  Scenario: Implausibly old goat birth date is rejected
    When birth date 2000-01-01 is validated for goat
    Then validation fails with code dobTooOld

  # --- Body condition score ---

  @positive
  Scenario: BCS 3.5 passes
    When BCS 3.5 is validated
    Then validation succeeds

  @positive
  Scenario: BCS at boundaries passes
    When BCS 1.0 is validated
    Then validation succeeds

  @negative
  Scenario: BCS below minimum is rejected
    When BCS 0.5 is validated
    Then validation fails with code bcsBelowMin

  @negative
  Scenario: BCS above maximum is rejected
    When BCS 5.5 is validated
    Then validation fails with code bcsAboveMax

  @negative
  Scenario: BCS not on half-step is rejected
    When BCS 3.3 is validated
    Then validation fails with code bcsNotHalfStep

  # --- Combined new animal ---

  @positive
  Scenario: Complete valid new animal passes
    When a new cattle animal has tag "NEW1" weight "400" and birth 2022-01-10
    Then validation succeeds

  @negative
  Scenario: New animal with negative weight and future DOB fails
    When a new cattle animal has tag "NEW2" weight "-5" and birth 2027-01-01
    Then validation reports multiple issues
