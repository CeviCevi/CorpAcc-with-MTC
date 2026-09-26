import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius = 12,
    this.contentPadding,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final Color effectiveBorder = hasError
        ? (widget.errorBorderColor ?? theme.colorScheme.error)
        : _isFocused
        ? (widget.focusedBorderColor ?? theme.colorScheme.primary)
        : (widget.borderColor ?? theme.dividerColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style:
                widget.labelStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: hasError
                      ? theme.colorScheme.error
                      : theme.textTheme.bodyMedium?.color,
                ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color:
                widget.fillColor ??
                (widget.enabled
                    ? theme.inputDecorationTheme.fillColor ??
                          theme.colorScheme.surface
                    : theme.disabledColor.withAlpha((255 * 0.08).toInt())),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: effectiveBorder,
              width: _isFocused || hasError ? 1 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: effectiveBorder.withAlpha((255 * 0.15).toInt()),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: widget.obscureText,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            autofocus: widget.autofocus,
            style: widget.textStyle ?? theme.textTheme.bodyLarge,
            cursorColor: theme.colorScheme.primary,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle:
                  widget.hintStyle ??
                  theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              isDense: true,
              contentPadding:
                  widget.contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
          ),
        ),
        if (hasError || widget.helperText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              hasError ? widget.errorText! : widget.helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: hasError
                    ? theme.colorScheme.error
                    : theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
