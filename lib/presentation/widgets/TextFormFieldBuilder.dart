import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/core/theme/theme.dart';
import 'package:my_app/presentation/providers/themeProvider.dart';
import 'package:provider/provider.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final bool isRequired;
  final String? errorMessage;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool readOnly;
  final bool disabled;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final EdgeInsets? contentPadding;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.isRequired = false,
    this.errorMessage,
    this.readOnly = false,
    this.disabled = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.inputFormatters,
    this.onChanged,
    this.contentPadding,
  });

  @override
  AppTextFieldState createState() => AppTextFieldState();
}

class AppTextFieldState extends State<AppTextField> {
  late bool isObscured;
  late ThemeTokens root;

  @override
  void initState() {
    super.initState();
    isObscured = widget.obscureText;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final themeProvider = context.watch<ThemeProvider>();
    root = themeProvider.root!;
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(context),
        const SizedBox(height: 4),

        MouseRegion(
          cursor: widget.readOnly
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.basic,
          child: Tooltip(
            message: widget.readOnly ? 'Non-editable field' : '',
            child: AbsorbPointer(
              absorbing: widget.readOnly,
              child: TextFormField(
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                readOnly: widget.readOnly,
                enabled: !widget.disabled,
                obscureText: isObscured,
                inputFormatters: widget.inputFormatters,
                onChanged: widget.onChanged,

                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: root("form.input.content.placeholder"),
                  ),

                  filled: true,
                  fillColor: widget.disabled
                      ? root("form.input.background").withOpacity(0.5)
                      : root("form.input.background"),

                  contentPadding:
                      widget.contentPadding ??
                      const EdgeInsets.fromLTRB(20, 13, 10, 13),

                  // NORMAL BORDER
                  enabledBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: root("form.input.border.disabled"),
                    ),
                  ),

                  // FOCUSED BORDER
                  focusedBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: root("form.input.border.focused"),
                      width: 1.5,
                    ),
                  ),

                  //  ERROR BORDER (FIXED ISSUE)
                  errorBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: root("form.input.helper.error"),
                    ),
                  ),

                  //  FOCUSED ERROR BORDER
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: root("form.input.helper.error"),
                      width: 1.5,
                    ),
                  ),

                  // DISABLED BORDER
                  disabledBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: root("form.input.content.disabled"),
                    ),
                  ),

                  suffixIcon: widget.obscureText
                      ? IconButton(
                          icon: Icon(
                            isObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              isObscured = !isObscured;
                            });
                          },
                        )
                      : null,
                ),

                validator: (value) {
                  final v = value?.trim();

                  ///  Required check FIRST
                  if (widget.isRequired && (v == null || v.isEmpty)) {
                    return widget.errorMessage ?? 'This field is required';
                  }

                  ///  Custom validator
                  if (widget.validator != null) {
                    return widget.validator!(v);
                  }

                  return null;
                },

                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: widget.readOnly
                      ? root("form.input.content.disabled")
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLabel(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return RichText(
      text: TextSpan(
        text: widget.label,
        style: theme.bodyMedium?.copyWith(
          fontWeight: FontWeight.normal,
          color: root("form.label.default"),
        ),
        children: widget.isRequired
            ? [
                TextSpan(
                  text: ' *',
                  style: theme.bodyMedium?.copyWith(
                    color: root("form.input.helper.error"),
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}
