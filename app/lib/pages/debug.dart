import 'package:app/layout/MainLayout.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/header_card.widget.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/sliding_up/map.widget.dart';
import 'package:app/widget/stepper.widget.dart';
import 'package:flutter/material.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Center(
        child: Column(
          children: [
            ButtonActions(text: 'Button', variant: ButtonVariant.primary),
            ButtonActions(text: 'Button', variant: ButtonVariant.light),
            ButtonActions(text: 'Button', variant: ButtonVariant.outline),
            ButtonActions(text: 'Button', variant: ButtonVariant.warning),
            ButtonActions(text: 'Button', variant: ButtonVariant.danger),

            ButtonActions(
              text: 'Button',
              variant: ButtonVariant.primary,
              icon: Icons.add,
              iconPosition: IconPosition.right,
            ),
            ButtonActions(
              text: 'Button',
              variant: ButtonVariant.primary,
              icon: Icons.add,
              iconPosition: IconPosition.left,
            ),
            ButtonActions(text: 'Button', variant: ButtonVariant.light),
            ButtonActions(text: 'Button', variant: ButtonVariant.outline),
            ButtonActions(text: 'Button', variant: ButtonVariant.warning),
            ButtonActions(text: 'Button', variant: ButtonVariant.danger),

            ButtonUnderline(text: 'Button'),
            ButtonUnderline(text: 'Button', active: true),

            // HeaderCard(),
            InputField(
              label: 'Input',
              type: InputType.line,
              hintText: 'Input',
              validate: true,
              errorText: 'Error',
            ),
            InputField(
              label: 'Input',
              type: InputType.fill,
              hintText: 'Input',
              validate: true,
              errorText: 'Error',
            ),
            InputField(
              label: 'Input',
              type: InputType.fill,
              hintText: 'Input',
              validate: true,
              errorText: 'Error',
              suffixIcon: const Icon(Icons.add),
            ),

            ProfileWidgets.avatar(isEdited: true, size: ProfileSize.xl),
            ProfileWidgets.avatar(isEdited: true, size: ProfileSize.md),
            ProfileWidgets.avatar(isEdited: true, size: ProfileSize.sm),
            ProfileWidgets.avatar(isEdited: true, size: ProfileSize.xs),
            ProfileWidgets.avatar(isEdited: true, size: ProfileSize.xxs),
            StepperWidget(
              steps: [
                StepData(label: 'Step 1', active: true),
                StepData(label: 'Step 2', active: false),
                StepData(label: 'Step 3', active: false),
              ],
            ),

            StepperWidget(
              steps: [
                StepData(label: 'Step 1', active: true),
                StepData(label: 'Step 2', active: true),
                StepData(label: 'Step 3', active: true),
              ],
            ),

            StepperWidget(
              steps: [
                StepData(label: 'Step 1', active: true),
                StepData(label: 'Step 2', active: true),
                StepData(label: 'Step 3', active: true),
                StepData(label: 'Step 4', active: true),
              ],
            ),
            HeaderStepperCard(
              steps: [
                StepData(label: 'Step 1', active: true),
                StepData(label: 'Step 2', active: true),
                StepData(label: 'Step 3', active: true),
                StepData(label: 'Step 4', active: false),
              ],
            ),
            LocationSelectorPage(),
          ],
        ),
      ),
    );
  }
}
