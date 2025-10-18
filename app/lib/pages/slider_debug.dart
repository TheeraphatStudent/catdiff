import 'package:app/layout/MainLayout.dart';
import 'package:app/widget/sliding_up/sliding_template.dart';
import 'package:flutter/material.dart';

class SilderDebug extends StatefulWidget {
  const SilderDebug({super.key});

  @override
  State<SilderDebug> createState() => _SilderDebugState();
}

class _SilderDebugState extends State<SilderDebug> {
  void _closeSlider() {}

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Slider Debug Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          SlidingTemplate(
            isShowingAction: true,
            actionButtonText: 'Open Sliding Template',
            actionButtonIcon: Icons.arrow_upward,
            onModalClosed: _closeSlider,
            contentPadding: const EdgeInsets.all(16),
            topBarHeight: 70,
            customTopBar: Placeholder(
              child: Center(child: Text("Test header")),
            ),
            children: [
              Placeholder(
                child: Center(child: Text("Build place holder work")),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
