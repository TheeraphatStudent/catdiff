import 'package:app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum InputType { fill, line }

class InputField extends StatefulWidget {
  final String? label;
  final String hintText;
  final InputType type;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? errorText;

  final bool validate;
  final bool obscureText;
  final bool enabled;

  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onFocus;

  const InputField({
    super.key,
    this.label,
    required this.hintText,
    this.validate = true,
    this.type = InputType.line,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFocus,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasError = false;
  String get _errorText => widget.errorText ?? '';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    widget.onFocus?.call();
  }

  void _validateInput(String value) {
    if (!widget.validate) return;

    setState(() {
      if (value.isEmpty) {
        _hasError = true;
      } else if (value.length < 3) {
        _hasError = true;
      } else {
        _hasError = false;
      }
    });
  }

  Color _getBorderColor() {
    if (!widget.enabled) return AppColors.primary2.withOpacity(0.7);
    if (_hasError) return AppColors.darkDanger;
    if (_isFocused) return AppColors.primary1;
    return AppColors.primary2.withOpacity(0.7);
  }

  Color _getBackgroundColor() {
    if (widget.type == InputType.fill) {
      double opacity = _isFocused ? 0.1 : 0.07;
      if (!widget.enabled) return AppColors.primary1.withValues(alpha: opacity);
      if (_hasError) return AppColors.darkDanger.withValues(alpha: opacity);
      if (_isFocused) return AppColors.primary2.withValues(alpha: opacity);
      return AppColors.primary1.withValues(alpha: opacity);
    }

    return Colors.transparent;
  }

  Color _getIconColor() {
    double opacity = _isFocused ? 1.0 : 0.7;
    if (_hasError) return AppColors.darkDanger.withOpacity(opacity);
    return AppColors.primary2.withOpacity(opacity);
  }

  Color _getTextColor() {
    double opacity = _isFocused ? 1.0 : 0.7;
    if (!widget.enabled) return AppColors.primary2.withOpacity(0.5);
    return AppColors.primary1.withOpacity(opacity);
  }

  Color _getHintColor() {
    double opacity = _isFocused ? 0.8 : 0.5;
    return AppColors.primary2.withOpacity(opacity);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontFamily: 'Mali',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary1.withOpacity(_isFocused ? 1.0 : 0.7),
            ),
          ),
          const SizedBox(height: 8),
        ],

        Stack(
          children: [
            TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              onChanged: (value) {
                _validateInput(value);
                widget.onChanged?.call(value);
              },
              onFieldSubmitted: widget.onSubmitted,
              style: TextStyle(
                fontFamily: 'Mali',
                fontSize: 16,
                color: _getTextColor(),
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontFamily: 'Mali',
                  fontSize: 16,
                  color: _getHintColor(),
                ),
                suffixIcon: widget.suffixIcon != null
                    ? IconTheme(
                        data: IconThemeData(color: _getIconColor()),
                        child: widget.suffixIcon!,
                      )
                    : null,
                filled: widget.type == InputType.fill,
                fillColor: widget.type == InputType.fill
                    ? _getBackgroundColor()
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: widget.type == InputType.line
                    ? UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: _getBorderColor(),
                          width: 1,
                        ),
                      )
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _getBorderColor(),
                          width: _isFocused ? 2 : 1,
                        ),
                      ),
                enabledBorder: widget.type == InputType.line
                    ? UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: _getBorderColor(),
                          width: 1,
                        ),
                      )
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _getBorderColor(),
                          width: 1,
                        ),
                      ),
                focusedBorder: widget.type == InputType.line
                    ? UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: _getBorderColor(),
                          width: 2,
                        ),
                      )
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _getBorderColor(),
                          width: 2,
                        ),
                      ),
                errorBorder: widget.type == InputType.line
                    ? UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.darkDanger,
                          width: 2,
                        ),
                      )
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.darkDanger,
                          width: 2,
                        ),
                      ),
                focusedErrorBorder: widget.type == InputType.line
                    ? UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.darkDanger,
                          width: 2,
                        ),
                      )
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.darkDanger,
                          width: 2,
                        ),
                      ),
              ),
            ),
            if (widget.validate && (_hasError || _isFocused))
              Positioned(
                bottom: -20,
                right: 0,
                child: Text(
                  _hasError ? _errorText : '*Valid',
                  style: TextStyle(
                    fontFamily: 'Mali',
                    color: _hasError
                        ? AppColors.darkDanger
                        : AppColors.primary1,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        // if (widget.validate && (_hasError || _isFocused))
        //   const SizedBox(height: 24),
      ],
    );
  }
}
