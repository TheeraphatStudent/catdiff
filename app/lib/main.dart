import 'package:app/config/share/app_data.dart';
import 'package:app/pages/auth/login.page.dart';
import 'package:app/pages/auth/register.page.dart';
import 'package:app/pages/debug.dart';
import 'package:app/pages/map_debug.dart';
import 'package:app/pages/onboarding/onboarding.page.dart';
import 'package:app/pages/rider/raider_listprod.dart';
import 'package:app/pages/user/user_home.dart';
import 'package:app/types/user/role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(
    ChangeNotifierProvider<AppData>(
      create: (_) => AppData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (BuildContext context, AppData appData, _) {
        final ThemeData theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: appData.themeToken.color,
          ),
          scaffoldBackgroundColor: appData.themeToken.color,
          useMaterial3: true,
        );

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          // initialRoute: ,
          // initialRoute: '/rider',
          getPages: <GetPage<dynamic>>[
            GetPage(name: '/', page: () => const _RootLandingPage()),
            GetPage(name: '/onboarding', page: () => const OnBoardingPage()),
            GetPage(name: '/login', page: () => const LoginPage()),
            GetPage(name: '/register', page: () => const RegisterPage()),
            GetPage(name: '/user', page: () => const HomeScreen()),
            GetPage(name: '/rider', page: () => const RiderListProd()),
            GetPage(name: '/debug', page: () => const DebugPage()),
            GetPage(name: '/map-debug', page: () => const MapDebugPage()),
          ],
        );
      },
    );
  }
}

class _RootLandingPage extends StatelessWidget {
  const _RootLandingPage();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (BuildContext context, AppData appData, _) {
        final AppUser? user = appData.currentUser;
        if (user == null) {
          return const OnBoardingPage();
        }

        switch (user.role) {
          case UserRole.rider:
            return const RiderListProd();
          case UserRole.user:
            return const HomeScreen();
        }
      },
    );
  }
}
