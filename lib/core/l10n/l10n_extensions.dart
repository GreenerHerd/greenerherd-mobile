import 'package:flutter/widgets.dart';

import '../../data/models/enums.dart';
import 'gen/app_localizations.dart';

extension BuildContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

String localizedSpecies(Species species, AppLocalizations l10n) {
  return switch (species) {
    Species.cattle => l10n.cattle,
    Species.goat => l10n.goats,
    Species.sheep => l10n.sheep,
  };
}

String localizedSpeciesPurpose(SpeciesPurpose purpose, AppLocalizations l10n) {
  return switch (purpose) {
    SpeciesPurpose.milk => l10n.purposeMilk,
    SpeciesPurpose.meat => l10n.purposeMeat,
    SpeciesPurpose.both => l10n.purposeMilkMeat,
  };
}
