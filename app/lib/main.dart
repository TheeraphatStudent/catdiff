import 'package:app/config/share/app_data.dart';
import 'package:app/pages/auth/login.page.dart';
import 'package:app/pages/auth/register.page.dart';
import 'package:app/pages/debug.dart';
import 'package:app/pages/map_debug.dart';
import 'package:app/pages/rider/rider_home.dart';
import 'package:app/pages/user/sender_state_have_prod.dart';
import 'package:app/pages/user/sender_state_tracking.dart';
import 'package:app/pages/user/user_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'pages/onboarding/onboarding.page.dart';
import 'firebase_options.dart';
import 'package:app/utils/storage.helper.dart';
import 'package:app/types/role.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String _initialRoute;

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  void _determineInitialRoute() {
    if (StorageHelper.getToken() != null) {
      UserRole? role = StorageHelper.getRole();
      if (role == UserRole.user) {
        _initialRoute = '/user';
      } else if (role == UserRole.rider) {
        _initialRoute = '/rider';
      } else {
        _initialRoute = '/';
      }
    } else {
      _initialRoute = '/login';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: _initialRoute,
      // home: OnBoardingPage(),
      // home: DebugPage(),
      // home: DeliveryTrackingScreen(),
      getPages: [
        GetPage(name: '/debug', page: () => const DebugPage()),
        GetPage(name: '/', page: () => const OnBoardingPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),

        GetPage(name: '/user', page: () => HomeScreen()),
        GetPage(name: '/rider', page: () => RiderHome()),
      ],
    );
  }
}
