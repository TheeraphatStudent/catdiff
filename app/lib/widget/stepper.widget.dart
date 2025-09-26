import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';

class StepData {
  final String label;
  final bool active;
  final Widget? icon;

  StepData({required this.label, required this.active, this.icon});
}

class StepperWidget extends StatelessWidget {
  final List<StepData> steps;
  final Color activeColor;
  final Color inactiveColor;
  final Color completedColor;
  final TextStyle? activeTextStyle;
  final TextStyle? inactiveTextStyle;
  final double stepRadius;
  final double lineLength;
  final EdgeInsets? padding;

  const StepperWidget({
    Key? key,
    required this.steps,
    this.activeColor = const Color(0xFF819067),
    this.inactiveColor = const Color(0xFFC1C6BA),
    this.completedColor = const Color(0xFF819067),
    this.activeTextStyle,
    this.inactiveTextStyle,
    this.stepRadius = 16,
    this.lineLength = 100,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate current step as the last index where active is true
    int activeStep = -1;
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].active) {
        activeStep = i;
      }
    }
    // If no active step found, default to 0
    if (activeStep == -1) activeStep = 0;

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: EasyStepper(
        activeStep: activeStep,
        direction: Axis.horizontal,
        unreachedStepIconColor: inactiveColor,
        unreachedStepBorderColor: inactiveColor,
        unreachedStepTextColor: inactiveColor,
        showLoadingAnimation: false,
        stepRadius: stepRadius,
        showStepBorder: true,
        borderThickness: 2,
        padding: const EdgeInsets.all(0),
        stepAnimationDuration: const Duration(milliseconds: 300),
        activeStepBackgroundColor: const Color(0xFFECFFCC),
        activeStepBorderColor: activeColor,
        activeStepIconColor: activeColor,
        finishedStepBackgroundColor: completedColor,
        finishedStepBorderColor: completedColor,
        finishedStepIconColor: Colors.white,
        lineStyle: LineStyle(
          lineLength: lineLength,
          lineSpace: 4,
          lineType: LineType.normal,
          unreachedLineColor: inactiveColor.withOpacity(0.5),
          finishedLineColor: activeColor,
          activeLineColor: activeColor,
          lineThickness: 2,
        ),
        steps: steps.asMap().entries.map((entry) {
          int index = entry.key;
          StepData stepData = entry.value;
          bool isCompleted = index < activeStep;
          bool isActive = index == activeStep;
          bool isUnreached = index > activeStep;

          return EasyStep(
            // Always provide a custom step for consistent appearance
            customStep: Container(
              width: stepRadius * 2,
              height: stepRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? completedColor
                    : isActive
                    ? const Color(0xFFECFFCC)
                    : Colors.white,
                border: Border.all(
                  color: isCompleted || isActive ? activeColor : inactiveColor,
                  width: 2,
                ),
              ),
              child: stepData.icon != null
                  ? Center(child: stepData.icon)
                  : Center(
                      child: isCompleted
                          ? Icon(Icons.check, size: 16, color: Colors.white)
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive ? activeColor : inactiveColor,
                              ),
                            ),
                    ),
            ),
            customTitle: Text(
              stepData.label,
              style: isActive
                  ? (activeTextStyle ??
                        const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Mali',
                          fontWeight: FontWeight.w400,
                        ))
                  : (inactiveTextStyle ??
                        TextStyle(
                          color: inactiveColor,
                          fontSize: 13,
                          fontFamily: 'Mali',
                          fontWeight: FontWeight.w500,
                        )),
              textAlign: TextAlign.center,
            ),
            icon: const Icon(Icons.circle),
            title: stepData.label,
          );
        }).toList(),
      ),
    );
  }
}
