import 'package:flutter/material.dart';
import 'package:my_app/core/theme/theme.dart';
import 'package:my_app/presentation/providers/themeProvider.dart';
import 'package:provider/provider.dart';

enum IconPosition { prefix, suffix }

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool isLoading;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isDisabled = false,
    this.icon,
    this.iconPosition = IconPosition.prefix,
    this.isLoading = false,
    this.color,
  });

  @override
  State<PrimaryButton> createState() => PrimaryButtonState();
}

class PrimaryButtonState extends State<PrimaryButton> {
  late ThemeTokens root;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    root = context.watch<ThemeProvider>().root!;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: buildButtonStyle(context, widget, root),
      onPressed: widget.isDisabled ? null : widget.onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: buildChildren(context, widget, root),
      ),
    );
  }
}

Widget? buildIcon(IconData? icon, Color color) {
  if (icon == null) return null;
  return Icon(icon, size: 20, color: color);
}

Widget buildText(BuildContext context, String text, Color color) {
  return Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
  );
}

List<Widget> buildChildren(
  BuildContext context,
  PrimaryButton widget,
  ThemeTokens root,
) {
  Color buttonColor = widget.color ?? root("button.primary.background.default");
  final Color textColor = root("button.primary.content.default");

  if (widget.isLoading) {
    return [
      SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      ),
      const SizedBox(width: 8),
      buildText(context, widget.text, textColor),
    ];
  }

  final iconWidget = buildIcon(
    widget.icon,
    root("button.primary.content.default"),
  );
  final textWidget = buildText(
    context,
    widget.text,
    root("button.primary.content.default"),
  );

  final children = <Widget>[];

  if (widget.iconPosition == IconPosition.prefix && iconWidget != null) {
    children.add(iconWidget);
    children.add(const SizedBox(width: 6));
  }

  children.add(textWidget);

  if (widget.iconPosition == IconPosition.suffix && iconWidget != null) {
    children.add(const SizedBox(width: 6));
    children.add(iconWidget);
  }

  return children;
}

ButtonStyle buildButtonStyle(
  BuildContext context,
  PrimaryButton widget,
  ThemeTokens root,
) {
  final textTheme = Theme.of(context).textTheme;
  return ElevatedButton.styleFrom(
    backgroundColor: widget.isDisabled
        ? root("button.primary.content.disabled")
        : widget.color ?? root("button.primary.background.default"),
    foregroundColor: root("button.primary.content.default"),
    shadowColor: Colors.transparent,
    overlayColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    textStyle: textTheme.labelLarge?.copyWith(
      color: root("button.primary.content.default"),
      fontWeight: FontWeight.w600,
    ),
  );
}
