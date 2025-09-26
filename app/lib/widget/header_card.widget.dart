import 'dart:developer';

import 'package:app/widget/button.widget.dart';
import 'package:flutter/material.dart';

class HeaderCard extends StatelessWidget {
  const HeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 256,
      decoration: ShapeDecoration(
        color: const Color(0xFFFAFFF1) /* General-White */,
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
                active: true,
                onPressed: () => {log("On press login work")},
              ),
              ButtonUnderline(
                text: 'สมัครสมาชิก',
                active: false,
                onPressed: () => {log("On press register work")},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
