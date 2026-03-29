import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    final auth = context.read<AuthProvider>();

    await auth.signup(_userCtrl.text.trim(), _passCtrl.text.trim());

    /// ERROR HANDLE
    if (auth.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.error!)));
      return;
    }

    /// SUCCESS
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Signup Successful")));

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Center(
      child: SizedBox(
        width: 320,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Signup", style: TextStyle(fontSize: 22)),
              const SizedBox(height: 16),

              /// USERNAME
              TextFormField(
                controller: _userCtrl,
                decoration: const InputDecoration(labelText: "Username"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Username required" : null,
              ),

              /// PASSWORD
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 4 ? "Min 4 chars" : null,
              ),

              /// CONFIRM PASSWORD
              TextFormField(
                controller: _confirmCtrl,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                ),
                obscureText: true,
              ),

              const SizedBox(height: 20),

              /// LOADING BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : signup,
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Signup"),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text("Already have account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
