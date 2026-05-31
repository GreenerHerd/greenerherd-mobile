Feature: Offline cache and sync queue
  Phase 5 Drift offline-first for animals, groups, and tasks.

  @positive
  Scenario: Entity JSON codec round-trips an animal
    Given a sample animal in memory
    When the animal is encoded and decoded
    Then the animal tag and name match

  @positive
  Scenario: Local cache stores and loads animals
    Given an in-memory Drift database
    When animals are written to the cache for farm-1
    Then loading animals returns the same count and tag

  @positive
  Scenario: Sync queue receives offline task completion
    Given an in-memory Drift database
    When a task complete operation is enqueued
    Then the sync queue has one pending item

  @positive
  Scenario: Offline-first repository reads cache when API fails
    Given a hybrid animal repository with a failing gateway
    And animals primed in the local cache
    When listing animals while offline
    Then cached animals are returned

  @positive
  Scenario: Offline-first repository enqueues animal create when offline
    Given an offline-first animal repository with mock inner
    When creating an animal while offline
    Then the sync queue contains an animal create operation
