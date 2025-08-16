
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/quran_repository.dart';
import 'state/app_state.dart';
import 'screens/surah_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/continue_reading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = QuranRepository();
  final app = AppState(repo);
  await app.init();
  runApp(MultiProvider(
    providers: [
      Provider<QuranRepository>(create: (_) => repo),
      ChangeNotifierProvider<AppState>(create: (_) => app),
    ],
    child: const QuranApp(),
  ));
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final baseTheme = ThemeData(
      useMaterial3: true,
      fontFamily: null, // System font (Arabic supported)
      textTheme: Typography.blackCupertino.apply(fontSizeFactor: app.fontScale),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'القرآن الكريم',
      themeMode: app.themeMode,
      theme: baseTheme.copyWith(brightness: Brightness.light),
      darkTheme: baseTheme.copyWith(brightness: Brightness.dark),
      home: const _Home(),
      routes: {
        '/continue': (_) => const Scaffold(appBar: _AppBar(title: "متابعة القراءة"), body: ContinueReadingScreen()),
      },
    );
  }
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  int _index = 0;

  final _pages = const [
    SurahScreen(),
    FavoritesScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  final _titles = const ["السورة", "المفضلة", "بحث", "الإعدادات"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppBar(title: _titles[_index]),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'سورة'),
          NavigationDestination(icon: Icon(Icons.star_outline), label: 'المفضلة'),
          NavigationDestination(icon: Icon(Icons.search), label: 'بحث'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'إعدادات'),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _AppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title, textDirection: TextDirection.rtl),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
