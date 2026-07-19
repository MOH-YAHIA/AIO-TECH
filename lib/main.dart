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
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'EG')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
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
  int _sessionKey = 0;

  // Increments every time the user navigates TO Profile, or after login/logout.
  int _profileRefreshTrigger = 0;

  // --- Search History Triggers ---
  String? _homeInitialQuery;
  int _homeSearchTrigger = 0;

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
    setState(() {
      _profileRefreshTrigger++;
      _currentIndex = 2;
    });
  }

  Future<void> _onLogout() async {
    await _authService.logout();
    setState(() {
      _sessionKey++;
      _profileRefreshTrigger++;
      _currentIndex = 0;
    });
  }

  void onTap(int index) {
    setState(() {
      if (index == 6) _profileRefreshTrigger++;
      _currentIndex = index;
    });
  }

  // Handle clicking a product from the drawer history
  void _onSearchProduct(String productName) {
    setState(() {
      _homeInitialQuery = productName;
      _homeSearchTrigger++;
      _currentIndex = 2; // Switch to HomeScreen
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
    // Pass the trigger data to the HomeScreen
    HomeScreen(
      initialQuery: _homeInitialQuery,
      searchTriggerId: _homeSearchTrigger,
    ),
    const WatchList(),
    const Dashboard(),
    const Compare(),
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
          // Connect the new callback here
          onSearchProduct: (productName) {
            Navigator.pop(context); // Close the drawer first
            _onSearchProduct(productName);
          },
        ),
      ),
    );
  }
}