import 'package:app/config/share/app_data.dart';
import 'package:app/pages/auth/login.page.dart';
import 'package:app/pages/auth/register.page.dart';
import 'package:app/pages/debug-rider.dart';
import 'package:app/pages/debug.dart';
import 'package:app/pages/map_debug.dart';
import 'package:app/pages/onboarding/onboarding.page.dart';
import 'package:app/pages/profile/profile.page.dart';
import 'package:app/pages/rider/raider_listprod.dart';
import 'package:app/pages/rider/rider_job.dart';
import 'package:app/pages/slider_debug.dart';
import 'package:app/pages/user/sender_state_have_prod.dart';
import 'package:app/pages/user/tracking/overview.dart';
import 'package:app/pages/user/tracking/single_tracking.dart';
import 'package:app/pages/user/user_home.dart';
import 'package:app/service/delivery/rider_job.dart';
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
          initialRoute: '/',
          // initialRoute: '/rider',
          // initialRoute: '/debug-rider',
          getPages: <GetPage<dynamic>>[
            GetPage(name: '/', page: () => const _RootLoadingChecker()),
            GetPage(name: '/onboarding', page: () => const OnBoardingPage()),
            GetPage(name: '/login', page: () => const LoginPage()),
            GetPage(name: '/register', page: () => const RegisterPage()),

            GetPage(name: '/user', page: () => const HomeScreen()),
            GetPage(name: '/rider', page: () => const RiderListProd()),
            GetPage(name: '/rider-job', page: () => const RiderJobPage()),
            GetPage(name: '/debug', page: () => const DebugPage()),

            GetPage(name: '/profile', page: () => const ProfilePage()),

            // Tracking
            GetPage(
              name: "/overview", 
              page: () {
                final args = Get.arguments as Map<String, dynamic>?;
                final initialTabIsSender = args?['initialTabIsSender'] as bool?;
                return OverviewPage(initialTabIsSender: initialTabIsSender);
              },
            ),

            GetPage(
              name: '/single-tracking-test',
              page: () => const DeliveryTrackingScreen(),
            ),

            GetPage(
              name: '/single-tracking',
              page: () => const SingleTracking(),
            ),

            // GetPage(name: '/multi-tracking', page: () => const MockupMulti()),

            // Debug
            GetPage(name: '/debug', page: () => const DebugPage()),
            GetPage(name: '/debug-rider', page: () => const DebugRider()),
            GetPage(name: '/slider-debug', page: () => const SilderDebug()),
            GetPage(name: '/map-debug', page: () => const MapDebugPage()),
          ],
        );
      },
    );
  }
}

class _RootLoadingChecker extends StatefulWidget {
  const _RootLoadingChecker();

  @override
  State<_RootLoadingChecker> createState() => _RootLoadingCheckerState();
}

class _RootLoadingCheckerState extends State<_RootLoadingChecker> {
  bool _hasChecked = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (BuildContext context, AppData appData, _) {
        final user = appData.currentUser;

        if (!_hasChecked) {
          _hasChecked = true;

          Future.microtask(() async {
            if (user == null) {
              Get.offNamed('/onboarding');
            } else {
              switch (user.role) {
                case UserRole.rider:
                  final hasActiveJob = await DeliveryRiderJob.getRiderJobExist(
                    user.id,
                  );

                  if (hasActiveJob) {
                    final activeJob = await DeliveryRiderJob.getActiveRiderJob(
                      user.id,
                    );

                    if (activeJob != null) {
                      Get.offNamed(
                        '/rider-job',
                        arguments: {'deliveryJob': activeJob},
                      );
                    } else {
                      Get.offNamed('/rider');
                    }
                  } else {
                    Get.offNamed('/rider');
                  }
                  break;
                case UserRole.user:
                  Get.offNamed('/user');
                  break;
              }
            }
          });
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
