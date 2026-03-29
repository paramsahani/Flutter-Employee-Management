import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:my_app/presentation/providers/themeProvider.dart';

class GenericAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GenericAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final root = themeProvider.root!;
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    final auth = context.watch<AuthProvider>();

    /// CURRENT ROUTE CHECK
    final location = GoRouterState.of(context).uri.toString();
    final isAuthScreen = location == '/login' || location == '/signup';

    return AppBar(
      elevation: 0,
      backgroundColor: root("layout.surface.background"),
      automaticallyImplyLeading: false,
      centerTitle: false,

      title: const Text("Employee Management"),

      actions: [
        ///  THEME (ALWAYS SHOW)
        IconButton(
          tooltip: isDark ? "Light Mode" : "Dark Mode",
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () {
            themeProvider.toggleTheme();
          },
        ),

        ///  LOGOUT (ONLY IF NOT LOGIN/SIGNUP)
        if (!isAuthScreen && auth.isLoggedIn) // FINAL CONDITION
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await context.read<AuthProvider>().logout();

                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
      ],
    );
  }
}
