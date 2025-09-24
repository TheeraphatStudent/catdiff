import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingController extends GetxController {
  void goToLogin() {
    Get.toNamed('/login');
  }
}

class OnBoardingPage extends GetView<OnBoardingController> {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text("ส่งง่ายไดชัวร์")]);
  }
}
