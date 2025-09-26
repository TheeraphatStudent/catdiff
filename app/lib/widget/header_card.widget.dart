import 'dart:developer';

import 'package:app/config/theme/app_theme.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/stepper.widget.dart';
import 'package:flutter/material.dart';

enum Actions { login, register }

class HeaderCard extends StatelessWidget {
  final Function(Actions) onPressed;
  final Actions Function() activeState;

  const HeaderCard({
    super.key,
    required this.onPressed,
    required this.activeState,
  });

  @override
  Widget build(BuildContext context) {
    final currentActive = activeState();
    return Container(
      width: double.infinity,
      height: 256,
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x7F819067),
            blurRadius: 24,
            offset: Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 64,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(64),
              ),
              shadows: [
                BoxShadow(
                  color: Color.fromARGB(90, 129, 144, 103),
                  blurRadius: 24,
                  offset: Offset(0, 0.005),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(
                'lib/assets/icons/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 18,
            children: [
              ButtonUnderline(
                text: 'เข้าสู่ระบบ',
                active: currentActive == Actions.login,
                onPressed: () => onPressed(Actions.login),
              ),
              ButtonUnderline(
                text: 'สมัครสมาชิก',
                active: currentActive == Actions.register,
                onPressed: () => onPressed(Actions.register),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderStepperCard extends StatelessWidget {
  final List<StepData> steps;

  const HeaderStepperCard({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 196),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x7F819067),
            blurRadius: 24,
            offset: Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: ShapeDecoration(
                color: AppColors.grayInsight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Image.asset(
                'lib/assets/icons/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StepperWidget(steps: steps),
            ),
          ],
        ),
      ),
    );
  }
}
