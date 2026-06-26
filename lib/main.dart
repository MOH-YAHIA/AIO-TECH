import 'package:aio_tech/Screens/compare.dart';
import 'package:aio_tech/Screens/dashboard.dart';
import 'package:aio_tech/Screens/login.dart';
import 'package:aio_tech/Screens/profile.dart';
import 'package:aio_tech/Screens/sign_up.dart';
import 'package:aio_tech/Screens/watch_list.dart';
import 'package:aio_tech/Widgets/drawer_design.dart';
import 'package:aio_tech/utils/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'Screens/home_screen.dart';
import '../services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('ar', 'EG')],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'AIOtech',
      home: const MainWrapper(),
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  bool _isLoading = true;
  final AuthService _authService = AuthService();

  // Increments on logout → forces Login, SignUp, Profile to fully recreate
  // (disposes old State, clears controllers, clears cached futures).
  int _sessionKey = 0;

  // Increments every time the user navigates TO Profile, or after login/logout.
  // Profile watches this via didUpdateWidget and re-fetches SharedPreferences
  // whenever it changes — so it always shows current data regardless of when
  // IndexedStack first built it relative to _saveSession completing.
  int _profileRefreshTrigger = 0;

  @override
  void initState() {
    super.initState();
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final bool loggedIn = await _authService.isLoggedIn();
    if (mounted) {
      setState(() {
        _currentIndex = loggedIn ? 2 : 0;
        _isLoading = false;
      });
    }
  }

  void _onLoginSuccess() {
    // _saveSession has already fully completed before login() returned,
    // so incrementing the trigger here guarantees Profile re-reads
    // SharedPreferences AFTER all new account data is on disk.
    setState(() {
      _profileRefreshTrigger++;
      _currentIndex = 2;
    });
  }

  Future<void> _onLogout() async {
    await _authService.logout();
    setState(() {
      _sessionKey++;            // recreate Login, SignUp, Profile widgets
      _profileRefreshTrigger++; // reset trigger counter for the new session
      _currentIndex = 0;
    });
  }

  // Increments _profileRefreshTrigger whenever the user explicitly opens
  // Profile (index 6), so data is always fresh after an Edit Profile update.
  void onTap(int index) {
    setState(() {
      if (index == 6) _profileRefreshTrigger++;
      _currentIndex = index;
    });
  }

  List<Widget> get _pages => [
    Login(
      key: ValueKey('login_$_sessionKey'),
      onNavigateToSignUp: () => onTap(1),
      onSignUpSuccess: _onLoginSuccess,
    ),
    SignUp(
      key: ValueKey('signup_$_sessionKey'),
      onSignUpSuccess: _onLoginSuccess,
    ),
    HomeScreen(),
    WatchList(),
    Dashboard(),
    Compare(),
    Profile(
      key: ValueKey('profile_$_sessionKey'),
      refreshTrigger: _profileRefreshTrigger,
      onBackPressed: () => onTap(2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool isAuthScreen = _currentIndex == 0 || _currentIndex == 1 || _currentIndex == 6;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: isAuthScreen
            ? null
            : AppBar(
          backgroundColor:
          AppColors.secondarySurface.withOpacity(0.2),
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 35.0,
          ),
          elevation: 0,
          actions: <Widget>[
            IconButton(
              onPressed: () => onTap(6),
              icon: const Icon(Icons.account_circle),
              iconSize: 40,
              color: Colors.white,
            ),
          ],
        ),
        body: IndexedStack(index: _currentIndex, children: _pages),
        drawer: isAuthScreen
            ? null
            : DrawerDesign(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            Navigator.pop(context);
            if (index == 0) {
              _onLogout();
            } else {
              onTap(index);
            }
          },
        ),
      ),
    );
  }
}