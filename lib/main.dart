import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/gen/app_localizations.dart';
import 'core/config/app_config.dart';
import 'core/persistence/sync_providers.dart';
import 'core/providers/data_refresh.dart';
import 'core/providers/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/gh_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Expose labels in the DOM for Playwright / accessibility on web.
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const ProviderScope(child: GreenerHerdApp()));
}

class GreenerHerdApp extends ConsumerStatefulWidget {
  const GreenerHerdApp({super.key});

  @override
  ConsumerState<GreenerHerdApp> createState() => _GreenerHerdAppState();
}

class _GreenerHerdAppState extends ConsumerState<GreenerHerdApp> {
  @override
  void initState() {
    super.initState();
    if (AppConfig.useOfflineSync) {
      Future.microtask(() {
        if (mounted) ref.read(syncServiceProvider).drainQueue();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    if (AppConfig.useOfflineSync) {
      final sync = ref.read(syncServiceProvider);
      ref.listen(connectivityStreamProvider, (previous, next) async {
        final online = next.asData?.value ?? false;
        if (online) {
          await sync.drainQueue();
          refreshHerdDataProviders(ref);
        }
      });
    }

    return MaterialApp.router(
      title: 'GreenerHerd',
      theme: GhTheme.light(),
      darkTheme: GhTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
