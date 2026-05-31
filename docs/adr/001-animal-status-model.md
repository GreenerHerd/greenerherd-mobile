# ADR 001: Animal Status Model

## Context

Design handoff uses `tags[]` on animals (e.g. `PREGNANT`, `LACTATING`, `SICK`). Harness uses `AnimalTag` rows plus `Animal.status` and `cull_flagged`.

## Decision

- **Canonical in Dart**: `AnimalStatus` enum for lifecycle (`ACTIVE`, `SOLD`, `DECEASED`, `CULLED`) and `AnimalTagType` for stackable tags.
- **Design tag strings** map 1:1 to `AnimalTagType` (uppercase).
- `cull_flagged` is derived: true when `CULL` tag present and status still `ACTIVE`.
- `LACTATING` in design maps to tag + optional milk fields; not a separate status.

## Consequences

Mock and API layers normalize lowercase species (`cattle`) to `Species.CATTLE` at boundaries.
