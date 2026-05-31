Feature: Animal lifecycle rules
  As a herd manager
  I want lifecycle transitions enforced consistently
  So that tags and status reflect real events

  @positive
  Scenario: Cull flag can be added to active animal
    Given an active cow ready to breed
    When the animal is flagged for cull
    Then the cull tag is present

  @positive
  Scenario: Cull-flagged animal can be marked sold
    Given a cull-flagged cow
    When the animal is marked sold
    Then status is sold

  @positive
  Scenario: Sold animal can be returned to active
    Given a sold cow
    When the sale is undone
    Then status is active

  @positive
  Scenario: Female can be marked ready to breed
    Given an active female cow
    When marked ready to breed
    Then readyToBreed tag is present

  @positive
  Scenario: Live birth adds lactating without duplicate
    Given a pregnant cow
    When calving outcome is born live
    Then lactating tag is present once

  @positive
  Scenario: Stillborn does not add lactating
    Given a pregnant cow
    When calving outcome is stillborn
    Then stillborn tag is present
    And lactating tag is absent

  @negative
  Scenario: Cannot cull a sold animal
    Given a sold cow
    When flagged for cull
    Then an error is thrown

  @positive
  Scenario: Active animal can be sold without cull flag
    Given an active cow without cull
    When marked sold
    Then status is sold
    And group membership is cleared

  @negative
  Scenario: Cannot sell an animal that is already sold
    Given a sold cow
    When marked sold again
    Then an error is thrown

  @negative
  Scenario: Bull cattle cannot be marked ready to breed
    Given an active male cattle
    When marked ready to breed
    Then an error is thrown

  @negative
  Scenario: Pregnant cow cannot be marked ready to breed
    Given a pregnant cow
    When marked ready to breed
    Then an error is thrown

  @negative
  Scenario: Milk is blocked during withdrawal
    Given a lactating cow with withdrawal days remaining
    Then milk recording is blocked

  @positive
  Scenario: Milk allowed when lactating and no withdrawal
    Given a lactating cow with no withdrawal
    Then milk recording is allowed
