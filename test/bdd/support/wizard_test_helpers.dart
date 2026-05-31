import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenerherd_mobile/shared/widgets/gh_group_name_field.dart';

/// Shared helpers for add-animal / add-group wizard widget BDD tests.
class WizardTestHelpers {
  WizardTestHelpers._();

  static String uniqueTag() =>
      'BDD${DateTime.now().millisecondsSinceEpoch % 1000000}';

  static Future<void> tapContinue(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
  }

  static Future<void> tapBack(WidgetTester tester) async {
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
  }

  static Future<void> enterAnimalTag(
    WidgetTester tester,
    String tag, {
    bool useKey = true,
  }) async {
    if (useKey) {
      await tester.enterText(find.byKey(const Key('add_animal_tag')), tag);
      return;
    }
    await tester.enterText(
      find.widgetWithText(TextField, 'e.g. 0473'),
      tag,
    );
  }

  /// Step 0: tag → step 1: weight (+ breed) → step 2: group / save.
  static Future<void> advanceAnimalWizardToSaveStep(
    WidgetTester tester, {
    required String tag,
    String weight = '350',
  }) async {
    await enterAnimalTag(tester, tag);
    await tapContinue(tester);
    final weightField = find.byKey(const Key('add_animal_weight'));
    if (weightField.evaluate().isNotEmpty) {
      await tester.enterText(weightField, weight);
    } else {
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. 412'),
        weight,
      );
    }
    await tapContinue(tester);
  }

  static Future<void> tapSaveAnimal(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Save animal'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save animal'));
    await tester.pumpAndSettle();
  }

  static Future<void> tapWizardPrimary(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(FilledButton, label));
    await tester.pumpAndSettle();
  }

  static Future<void> openDropdownByLabel(
    WidgetTester tester,
    String label,
  ) async {
    final field = find.widgetWithText(DropdownButtonFormField<dynamic>, label);
    if (field.evaluate().isEmpty) {
      await tester.tap(find.text(label).first);
    } else {
      await tester.tap(field);
    }
    await tester.pumpAndSettle();
  }

  static Future<void> selectBornLivestockOrigin(WidgetTester tester) async {
    await tester.tap(find.text('New (born)').first);
    await tester.pumpAndSettle();
  }

  static Future<void> addLivestockRow(WidgetTester tester) async {
    final addBtn = find.textContaining('Add').evaluate().isNotEmpty
        ? find.textContaining(RegExp(r'Add.*livestock|Add animal', caseSensitive: false)).first
        : find.byIcon(Icons.add);
    await tester.tap(addBtn);
    await tester.pumpAndSettle();
  }

  static Future<void> enterGroupName(
    WidgetTester tester,
    String name,
  ) async {
    final field = find.byType(GhGroupNameField);
    if (field.evaluate().isEmpty) {
      await tester.enterText(
        find.widgetWithText(TextField, 'Group name'),
        name,
      );
    } else {
      await tester.enterText(field, name);
    }
    await tester.pump();
  }

  /// Step 0 → herd step (wizard) or livestock step (sheet).
  static Future<void> advanceGroupDetailsStep(WidgetTester tester) async {
    await tapContinue(tester);
  }

  /// Wizard step 1 → animals step (existing/born origin).
  static Future<void> advanceGroupHerdStep(
    WidgetTester tester, {
    String headCount = '2',
  }) async {
    final countField = find.widgetWithText(TextField, 'Number in group');
    if (countField.evaluate().isNotEmpty) {
      await tester.enterText(countField, headCount);
    }
    await tapContinue(tester);
  }

  static Future<void> enterAlertDialogText(
    WidgetTester tester,
    String text,
  ) async {
    final field = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    expect(field, findsOneWidget);
    await tester.enterText(field, text);
    await tester.pump();
  }

  static Future<void> tapMemberStatusIcon(
    WidgetTester tester,
    IconData icon,
  ) async {
    final target = find.byIcon(icon).first;
    await tester.scrollUntilVisible(
      target,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  static Future<void> tapMemberStatusTooltip(
    WidgetTester tester,
    String tooltip,
  ) async {
    final target = find.byTooltip(tooltip).first;
    await tester.scrollUntilVisible(
      target,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  static Future<void> enableGroupWizardVaccination(WidgetTester tester) async {
    final tile = find.ancestor(
      of: find.text('Vaccinated'),
      matching: find.byType(SwitchListTile),
    );
    expect(tile, findsOneWidget);
    await tester.tap(find.descendant(of: tile, matching: find.byType(Switch)));
    await tester.pumpAndSettle();
  }

  /// Opens add-group wizard step 3 (individual animals).
  static Future<void> advanceGroupWizardToAnimalsStep(
    WidgetTester tester, {
    String groupName = 'BDD herd',
    String headCount = '2',
  }) async {
    await enterGroupName(tester, groupName);
    await advanceGroupDetailsStep(tester);
    await advanceGroupHerdStep(tester, headCount: headCount);
  }

  /// Collects layout overflow errors during a pump (debug builds).
  static Future<List<FlutterErrorDetails>> pumpWithOverflowWatch(
    WidgetTester tester,
    Future<void> Function() action,
  ) async {
    final overflows = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('overflowed') ||
          message.contains('RenderFlex overflow')) {
        overflows.add(details);
      }
      previous?.call(details);
    };
    try {
      await action();
      await tester.pumpAndSettle();
    } finally {
      FlutterError.onError = previous;
    }
    return overflows;
  }
}
