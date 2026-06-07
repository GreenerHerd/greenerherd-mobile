import '../../core/l10n/gen/app_localizations.dart';

/// Milking session for a single day's yield record.
enum MilkingSession {
  morning,
  evening,
  daily,
}

extension MilkingSessionWire on MilkingSession {
  String get wire => switch (this) {
        MilkingSession.morning => 'AM',
        MilkingSession.evening => 'PM',
        MilkingSession.daily => 'DAILY',
      };

  static MilkingSession? fromWire(String? value) => switch (value) {
        'AM' => MilkingSession.morning,
        'PM' => MilkingSession.evening,
        'DAILY' => MilkingSession.daily,
        _ => null,
      };

  String label(AppLocalizations l10n) => switch (this) {
        MilkingSession.morning => l10n.milkSessionMorning,
        MilkingSession.evening => l10n.milkSessionEvening,
        MilkingSession.daily => l10n.milkSessionDaily,
      };
}
