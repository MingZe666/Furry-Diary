import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'l10n/generated/app_localizations.dart';

import 'pages/home_page.dart';
import 'pages/health_grid_page.dart';
import 'pages/pet_profile_page.dart';
import 'pages/settings_page.dart';
import 'services/local_store.dart';
import 'services/auto_backup_service.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStore = LocalStore();
  await localStore.init();

  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(localStore),
      ],
      child: MyApp(localStore: localStore),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key, required this.localStore});

  final LocalStore localStore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Furry Diary',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'),
        Locale('en'),
      ],
      locale: locale,
      theme: ThemeData(
        fontFamily: 'sans-serif-rounded', // Use rounded font if available
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8A65), // Coral/Warm Orange
          primary: const Color(0xFFFF8A65),
          secondary: const Color(0xFF81C784), // Mint Green for health
          tertiary: const Color(0xFF64B5F6), // Baby Blue
          surface: const Color(0xFFFFF8DC), // Warm cream
        ),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF4E342E), // Dark brown for text
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(24))), // Super rounded
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: const StadiumBorder(), // Stadium border for buttons
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: AppShell(localStore: localStore),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.localStore});

  final LocalStore localStore;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;

  void _onLocalDataChanged() {
    AutoBackupService.instance.onDataChanged(widget.localStore);
  }

  @override
  void initState() {
    super.initState();
    widget.localStore.dataChangedNotifier.addListener(_onLocalDataChanged);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localStore != widget.localStore) {
      oldWidget.localStore.dataChangedNotifier
          .removeListener(_onLocalDataChanged);
      widget.localStore.dataChangedNotifier.addListener(_onLocalDataChanged);
    }
  }

  @override
  void dispose() {
    widget.localStore.dataChangedNotifier.removeListener(_onLocalDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final navBar = BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (value) => setState(() => currentIndex = value),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_rounded),
          activeIcon: const Icon(Icons.home_rounded)
              .animate()
              .scale(duration: 200.ms, curve: Curves.easeOutBack)
              .tint(color: Theme.of(context).colorScheme.primary),
          label: l10n.tabHome,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.pets_rounded),
          activeIcon: const Icon(Icons.pets_rounded)
              .animate()
              .scale(duration: 200.ms, curve: Curves.easeOutBack)
              .tint(color: Theme.of(context).colorScheme.primary),
          label: l10n.tabProfiles,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long_rounded),
          activeIcon: const Icon(Icons.receipt_long_rounded)
              .animate()
              .scale(duration: 200.ms, curve: Curves.easeOutBack)
              .tint(color: Theme.of(context).colorScheme.primary),
          label: l10n.tabRecords,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_rounded),
          activeIcon: const Icon(Icons.person_rounded)
              .animate()
              .scale(duration: 200.ms, curve: Curves.easeOutBack)
              .tint(color: Theme.of(context).colorScheme.primary),
          label: l10n.tabMine,
        ),
      ],
    );

    final pages = [
      HomePage(localStore: widget.localStore, bottomNavigationBar: navBar),
      PetProfilePage(
          localStore: widget.localStore,
          isPro: false,
          bottomNavigationBar: navBar),
      HealthGridPage(
          localStore: widget.localStore,
          isPro: false,
          bottomNavigationBar: navBar),
      SettingsPage(isPro: false, bottomNavigationBar: navBar),
    ];

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          setState(() => currentIndex = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: pages),
      ),
    );
  }
}
