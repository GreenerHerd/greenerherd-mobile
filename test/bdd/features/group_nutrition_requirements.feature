# Group nutrition requirements

Ensures daily nutritional needs are calculated per animal, then summed for the group total.

## Group purpose rules

Only **breeding**, **maintenance**, and **fattening** group purposes apply to untagged animals.
Individual tags (lactating, pregnant, sick, weaning, fattening, ready to breed) always take precedence.

| Group purpose | Applies when |
|---------------|--------------|
| Fattening | Member has no individual nutrition state tag |
| Maintenance | Member has no individual nutrition state tag |
| Breeding | Member has no individual nutrition state tag (Ready to Breed tag equivalent) |
| Sick / weaning / milk / pregnant | **Not** forced from group purpose — use animal tags |

Lactating cattle use per-animal `monthsSinceCalving` to pick fresh / early / mid / late dairy profiles.

## Run

```bash
flutter test test/bdd/group_nutrition_requirements_bdd_test.dart
```
