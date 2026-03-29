import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:my_app/presentation/providers/auth_provider.dart';
import 'package:my_app/presentation/providers/themeProvider.dart';
import 'package:my_app/presentation/widgets/PrimaryButton.dart';
import 'package:my_app/presentation/widgets/TextFormFieldBuilder.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscure = true;
  bool _rememberMe = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    await auth.login(_userCtrl.text.trim(), _passCtrl.text.trim());

    ///  ERROR HANDLE
    if (auth.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.error!)));
      return;
    }

    /// SUCCESS
    context.go('/employee');
  }

  @override
  Widget build(BuildContext context) {
    final root = context.watch<ThemeProvider>().root;
    final auth = context.watch<AuthProvider>();

    return ResponsiveBuilder(
      builder: (context, size) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFD8B5), Color(0xFFC1EEFD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            Row(
              children: [
                /// LEFT SIDE
                Expanded(
                  flex: size.isMobile ? 1 : 2,
                  child: Center(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color:
                          root?.call("form.input.background") ?? Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: Form(
                          key: _formKey,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 350),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Welcome",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 24),

                                /// USERNAME
                                AppTextField(
                                  label: "User ID",
                                  controller: _userCtrl,
                                  isRequired: true,
                                  hint: "Enter User ID",
                                  errorMessage: "Enter User ID",
                                ),

                                const SizedBox(height: 20),

                                /// PASSWORD
                                AppTextField(
                                  label: "Password",
                                  controller: _passCtrl,
                                  obscureText: _obscure,
                                  isRequired: true,
                                  hint: "Enter Password",
                                  errorMessage: "Enter password",
                                ),

                                const SizedBox(height: 16),

                                /// REMEMBER + FORGOT
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (v) {
                                        setState(() {
                                          _rememberMe = v ?? false;
                                        });
                                      },
                                    ),
                                    const Text("Remember Me"),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text("Forgot Password?"),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                ///  LOGIN BUTTON WITH LOADING
                                SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: PrimaryButton(
                                    text: auth.isLoading
                                        ? "Please wait..."
                                        : "LOGIN",
                                    onPressed: auth.isLoading ? null : login,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Don't have an account?"),
                                    TextButton(
                                      onPressed: () => context.go('/signup'),
                                      child: const Text("Signup"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                /// RIGHT IMAGE (DESKTOP)
                if (!size.isMobile)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/login-screen-placeholder-image.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
