import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/presentation/providers/themeProvider.dart';
import 'package:my_app/presentation/widgets/appBar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final root = themeProvider.root;
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// CONSTANT APPBAR
            Container(
              decoration: BoxDecoration(
                color: root == null ? Colors.white : root("layout.background"),
                border: isDark
                    ? const Border(bottom: BorderSide(color: Color(0x1AFFFFFF)))
                    : null,
              ),
              child: const GenericAppBar(),
            ),

            ///  PAGE CONTENT
            Expanded(
              child: Container(
                width: double.infinity,
                color: root == null ? Colors.white : root("layout.background"),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
