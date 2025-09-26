import 'dart:developer';

import 'package:app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum ButtonVariant { primary, light, outline, warning, danger }

class ButtonActions extends StatefulWidget {
  const ButtonActions({
    super.key,
    required this.text,
    this.label,
    this.hasShadow = true,
    required this.variant,
    this.theme,
    this.onPressed,
    this.icon,
    this.onLabelPressed,
    this.iconPosition = IconPosition.right,
    this.height = 48,
  });

  final String text;
  final String? label;
  final bool hasShadow;
  final ButtonVariant variant;
  final Color? theme;
  final IconData? icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLabelPressed;
  final double? height;

  final IconPosition iconPosition;

  @override
  State<ButtonActions> createState() => _ButtonActionsState();
}

enum IconPosition { left, right }

class _ButtonActionsState extends State<ButtonActions>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    log("_handleTapDown work");
    log(details.toString());

    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    log("_handleTapUp");
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    log("_handleTapCancel");
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.theme ?? AppColors.primary3;

    final bool isSecondaryTheme = widget.theme == AppColors.primary5;
    final Color effectiveAccent = isSecondaryTheme
        ? AppColors.primary5
        : AppColors.primary1;

    final Color backgroundColor;
    final Color foregroundColor;
    final OutlinedBorder shape;

    final List<BoxShadow> boxShadows = widget.hasShadow
        ? [
            BoxShadow(
              color:
                  (widget.variant == ButtonVariant.warning
                          ? AppColors.lightWarning
                          : effectiveAccent)
                      .withOpacity(_isHovered ? 0.35 : 0.25),
              blurRadius: _isHovered ? 12 : 8,
              offset: Offset(0, _isHovered ? 6 : 4),
              spreadRadius: _isHovered ? 1 : 0,
            ),
          ]
        : const [];

    switch (widget.variant) {
      case ButtonVariant.primary:
        backgroundColor = _isHovered
            ? Color.lerp(accent, AppColors.primary2, 0.1)!
            : accent;
        foregroundColor = isSecondaryTheme ? AppColors.primary5 : Colors.white;
        shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
        break;

      case ButtonVariant.light:
        backgroundColor = _isHovered
            ? Color.lerp(AppColors.primary5, effectiveAccent, 0.05)!
            : AppColors.primary5;
        foregroundColor = effectiveAccent;
        shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
        break;

      case ButtonVariant.outline:
        backgroundColor = _isHovered
            ? effectiveAccent.withOpacity(0.05)
            : AppColors.primary5;
        foregroundColor = effectiveAccent;
        shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _isHovered
                ? AppColors.primary1
                : AppColors.primary1.withValues(alpha: 0.8),
            width: _isHovered ? 2.5 : 2,
          ),
        );
        break;

      case ButtonVariant.warning:
        backgroundColor = _isHovered
            ? Color.lerp(AppColors.lightWarning, AppColors.darkWarning, 0.1)!
            : AppColors.lightWarning;
        foregroundColor = AppColors.darkWarning;
        shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _isHovered
                ? AppColors.darkWarning
                : AppColors.darkWarning.withOpacity(0.8),
            width: _isHovered ? 2.5 : 2,
          ),
        );
        break;
      case ButtonVariant.danger:
        backgroundColor = _isHovered
            ? Color.lerp(AppColors.lightDanger, AppColors.darkDanger, 0.1)!
            : AppColors.lightDanger;
        foregroundColor = AppColors.darkDanger;
        shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _isHovered
                ? AppColors.darkDanger
                : AppColors.darkDanger.withOpacity(0.8),
            width: _isHovered ? 2.5 : 2,
          ),
        );
        break;
    }

    final buttonWidget = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: widget.onPressed,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Container(
                    width: double.infinity,
                    height: widget.height,
                    decoration: ShapeDecoration(
                      color: backgroundColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: AppColors.black),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      shadows: widget.hasShadow ? boxShadows : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: widget.icon != null
                            ? (widget.iconPosition == IconPosition.left
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.end)
                            : MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (widget.icon != null &&
                              widget.iconPosition == IconPosition.left)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              transform: Matrix4.translationValues(
                                _isHovered ? -2 : 0,
                                0,
                                0,
                              ),
                              child: Icon(
                                widget.icon,
                                size: 24,
                                color: foregroundColor,
                              ),
                            ),

                          if (widget.icon == null)
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                color: foregroundColor,
                                fontSize: 16,
                                fontFamily: 'Mali',
                                fontWeight: FontWeight.w700,
                              ),
                              child: Text(widget.text),
                            ),

                          if (widget.icon != null)
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  color: foregroundColor,
                                  fontSize: 16,
                                  fontFamily: 'Mali',
                                  fontWeight: FontWeight.w700,
                                ),
                                child: Text(
                                  widget.text,
                                  textAlign:
                                      widget.iconPosition == IconPosition.left
                                      ? TextAlign.right
                                      : TextAlign.left,
                                ),
                              ),
                            ),

                          if (widget.icon != null &&
                              widget.iconPosition == IconPosition.right)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              transform: Matrix4.translationValues(
                                _isHovered ? 2 : 0,
                                0,
                                0,
                              ),
                              child: Icon(
                                widget.icon,
                                size: 24,
                                color: foregroundColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.label == null || widget.label!.isEmpty) {
      return buttonWidget;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.onLabelPressed,
          child: Text(
            widget.label!,
            style: const TextStyle(
              color: Colors.yellow,
              decoration: TextDecoration.underline,
              decorationColor: Colors.yellow,
              fontSize: 16,
              fontFamily: 'Mali',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        buttonWidget,
      ],
    );
  }
}

class ButtonTab extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback? onTap;
  final double height;

  const ButtonTab({
    super.key,
    required this.text,
    required this.isActive,
    this.onTap,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          decoration: ShapeDecoration(
            color: AppColors.primary5,
            shape: RoundedRectangleBorder(
              side: isActive
                  ? BorderSide(width: 1, color: AppColors.darkDanger)
                  : BorderSide.none,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? AppColors.darkDanger : AppColors.lightDanger,
                fontSize: 14,
                fontFamily: 'Mali',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonUnderline extends StatefulWidget {
  const ButtonUnderline({
    super.key,
    required this.text,
    this.onPressed,
    this.active = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool active;

  @override
  State<ButtonUnderline> createState() => _ButtonUnderlineState();
}

class _ButtonUnderlineState extends State<ButtonUnderline>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 128),
              child: Container(
                width: 156,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: widget.active
                      ? Border(
                          bottom: BorderSide(
                            width: 2,
                            color: AppColors.primary1,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.active
                            ? AppColors.primary1
                            : AppColors.primary2.withOpacity(0.7),
                        fontSize: 20,
                        fontFamily: 'Mali',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
