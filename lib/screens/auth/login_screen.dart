import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _authService = AuthService();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.signIn(email: _email.text.trim(), password: _password.text);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
    } catch (e) {
      setState(() => _error = 'Login failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                Text('Welcome Back!',
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.dark)),
                SizedBox(height: 6),
                Text('Login to continue',
                    style: TextStyle(fontSize: 15, color: AppColors.grey)),
                SizedBox(height: 32),
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _email,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _password,
                  icon: Icons.lock_outline,
                  obscureText: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.grey, size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Password too short' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: TextStyle(color: AppColors.danger)),
                  ),
                SizedBox(height: 8),
                PrimaryButton(label: 'Login', onPressed: _login, loading: _loading),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.lightGrey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or continue with', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                    ),
                    Expanded(child: Divider(color: AppColors.lightGrey)),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(Icons.g_mobiledata_rounded),
                    SizedBox(width: 16),
                    _socialButton(Icons.facebook_rounded),
                  ],
                ),
                SizedBox(height: 32),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                          style: TextStyle(color: AppColors.grey)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.register),
                        child: Text('Sign Up',
                            style: TextStyle(
                                color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon) {
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: AppColors.dark),
    );
  }
}
