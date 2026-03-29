import 'package:flutter/material.dart';
import 'package:my_app/core/theme/theme.dart';
import 'package:my_app/presentation/providers/themeProvider.dart';
import 'package:provider/provider.dart';

class SecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  State<SecondaryButton> createState() => SecondaryButtonState();
}

class SecondaryButtonState extends State<SecondaryButton> {
  late ThemeTokens root;
  late bool isDark;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final themeProvider = context.read<ThemeProvider>();
    root = context.watch<ThemeProvider>().root!;
    isDark = themeProvider.themeMode == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          isDark
              ? Colors
                    .transparent //changed
              : root!("form.input.background"),
        ),
        side: WidgetStateProperty.all(
          BorderSide(color: root!("button.primary.background.default")),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        textStyle: WidgetStateProperty.all(
          Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        foregroundColor: WidgetStateProperty.all(
          root("button.primary.background.default"),
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent), //changed
        shadowColor: WidgetStateProperty.all(Colors.transparent),
      ),
      onPressed: widget.isDisabled ? null : widget.onPressed,
      child: Text(
        widget.text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: widget.textColor ?? root("button.secondary.content.default"),
        ),
      ),
    );
  }
}
