import 'package:app/layout/MainLayout.dart';
import 'package:flutter/material.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Placeholder(child: Center(child: Text("Debug"))),
    );
  }
}
