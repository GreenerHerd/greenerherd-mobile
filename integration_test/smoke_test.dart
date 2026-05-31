import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:greenerherd_mobile/main.dart' as app;

/// Device/emulator smoke test (mobile E2E equivalent to Playwright on web).
///
/// Run:
///   flutter test integration_test/smoke_test.dart -d <device_id>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches and shows sign-in providers', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 8));
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Greener Herd'), findsOneWidget);
  });
}
