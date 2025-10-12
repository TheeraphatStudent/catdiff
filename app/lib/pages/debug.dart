import 'package:app/layout/MainLayout.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/sliding_up/map.widget.dart';
import 'package:flutter/material.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Column(
        children: [
          InputField(hintText: "ตำแหน่งที่อยู่"),
          MapsLocationSelector(isOpened: true),
        ],
      ),
    );
  }
}
