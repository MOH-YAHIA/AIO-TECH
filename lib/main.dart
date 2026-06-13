import 'package:aio_tech/Screens/dashboard.dart';
import 'package:aio_tech/Screens/login.dart';
import 'package:aio_tech/Screens/sign_up.dart';
import 'package:aio_tech/Screens/watch_list.dart';
import 'package:aio_tech/Widgets/drawer_design.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'Screens/home_screen.dart';

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
  int _currentIndex = 2;

  List<Widget> get _pages => [
    Login(
      onNavigateToSignUp: () {
        onTap(1);
      },
      onSignUpSuccess: () {
        onTap(2); // Navigates to HomeScreen
      },
    ),    SignUp(
      onSignUpSuccess: () {
        onTap(2); // Navigates to HomeScreen
      },
    ),
     HomeScreen(),
     WatchList(),
     Dashboard(),
  ];

  void onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle),
            iconSize: 40,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      drawer: DrawerDesign(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          Navigator.pop(context);
          onTap(index);
        },
      ),
    );
  }
}