import 'package:app/layout/MainLayout.dart';
import 'package:app/widget/button.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:app/config/share/app_data.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnBoardingController extends GetxController {
  void goToLogin() {
    Get.toNamed('/login');
  }
}

class OnBoardingPage extends GetView<OnBoardingController> {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    Get.put(OnBoardingController());

    return MainLayout(
      scrollable: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFAFFF1), // General-White
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(48),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const ShapeDecoration(
                            image: DecorationImage(
                              image: AssetImage('lib/assets/icons/logo.png'),
                              fit: BoxFit.cover,
                            ),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title text
                      Text(
                        'ส่งง่าย ไดชัวร์',
                        style: TextStyle(
                          color: const Color(0xFF0A400C), // Primary-Green1
                          fontSize: 32,
                          fontFamily: 'Mali',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Positioned(
                //   bottom: 180,
                //   left: -60,
                //   child: Container(
                //     width: 280,
                //     height: 350,
                //     child: SvgPicture.asset(
                //       'lib/assets/images/logo_mascot.svg',
                //       fit: BoxFit.contain,
                //       placeholderBuilder: (BuildContext context) => Container(
                //         width: 280,
                //         height: 350,
                //         decoration: BoxDecoration(
                //           color: Colors.grey.shade300,
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //         child: const Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Icon(Icons.image, size: 48, color: Colors.grey),
                //             SizedBox(height: 8),
                //             Text(
                //               'Loading SVG...',
                //               style: TextStyle(color: Colors.grey),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Positioned(
                  bottom: -100,
                  left: -120,
                  child: Container(
                    width: 420,
                    height: 590,
                    child: Image(
                      image: AssetImage('lib/assets/images/logo_mascot.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Bottom gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 250,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFD3ECA5).withOpacity(0.0),
                          const Color(0xFFD3ECA5).withOpacity(0.7),
                          const Color(0xFFD3ECA5),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Login button at bottom
                Positioned(
                  bottom: 60,
                  left: 60,
                  right: 60,
                  child: ButtonActions(
                    text: 'ไปกันเลย',
                    variant: ButtonVariant.primary,
                    onPressed: () {
                      Get.toNamed('/login');
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
