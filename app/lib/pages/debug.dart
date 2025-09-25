import 'package:app/layout/MainLayout.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/header_card.widget.dart';
import 'package:flutter/material.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Center(
        child: Column(
          children: [
            // ButtonActions(text: 'Button', variant: ButtonVariant.primary),
            // ButtonActions(text: 'Button', variant: ButtonVariant.light),
            // ButtonActions(text: 'Button', variant: ButtonVariant.outline),
            // ButtonActions(text: 'Button', variant: ButtonVariant.warning),
            // ButtonActions(text: 'Button', variant: ButtonVariant.danger),

            // const SizedBox(height: 20),

            // ButtonActions(
            //   text: 'Button',
            //   variant: ButtonVariant.primary,
            //   icon: Icons.add,
            //   iconPosition: IconPosition.right,
            // ),
            // ButtonActions(
            //   text: 'Button',
            //   variant: ButtonVariant.primary,
            //   icon: Icons.add,
            //   iconPosition: IconPosition.left,
            // ),
            // ButtonActions(text: 'Button', variant: ButtonVariant.light),
            // ButtonActions(text: 'Button', variant: ButtonVariant.outline),
            // ButtonActions(text: 'Button', variant: ButtonVariant.warning),
            // ButtonActions(text: 'Button', variant: ButtonVariant.danger),
            // HeaderCard(),

            // ButtonUnderline(text: 'Button'),
            // ButtonUnderline(text: 'Button', active: true),

            
          ],
        ),
      ),
    );
  }
}
