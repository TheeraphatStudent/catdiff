import 'package:app/config/share/app_data.dart';
import 'package:app/pages/%E0%B8%B5user/home.dart';
import 'package:app/pages/auth/login.page.dart';
import 'package:app/pages/auth/register.page.dart';
import 'package:app/pages/debug.dart';
import 'package:app/pages/rider/rider_home.dart';
import 'package:app/pages/user/user_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'pages/onboarding/onboarding.page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GetStorage.init();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AppData())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/',
      home: OnBoardingPage(),
      // home: DebugPage(),
      getPages: [
        GetPage(name: '/debug', page: () => const DebugPage()),
        GetPage(name: '/', page: () => const OnBoardingPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/user', page: () => UserHomepage()),
        GetPage(name: '/rider', page: () => RiderHome()),
      ],
    );
  }
}
