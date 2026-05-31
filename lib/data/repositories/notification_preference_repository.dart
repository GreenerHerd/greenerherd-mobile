import '../models/notification_preference.dart';

abstract class NotificationPreferenceRepository {
  Future<NotificationPreferencesBundle> getPreferences();
  Future<NotificationPreferencesBundle> updatePreferences(
    List<NotificationPreferenceItem> items,
  );
}
