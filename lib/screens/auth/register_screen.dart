import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _experience = TextEditingController();
  final _caregiverRelation = TextEditingController();
  final _remuneration = TextEditingController();
  final _authService = AuthService();

  UserRole _role = UserRole.elder;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _confirm.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _authService.signUp(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
        role: _role,
        experience: _role == UserRole.caregiver && _experience.text.trim().isNotEmpty
            ? _experience.text.trim()
            : null,
        caregiverRelation:
            _role == UserRole.caregiver && _caregiverRelation.text.trim().isNotEmpty
                ? _caregiverRelation.text.trim()
                : null,
        remuneration: _role == UserRole.caregiver && _remuneration.text.trim().isNotEmpty
            ? _remuneration.text.trim()
            : null,
      );
      if (!mounted) return;
      if (response.session == null) {
        // Email confirmation is required — no active session yet.
        setState(() => _error = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created! Please check your email to confirm, then log in.'),
          ),
        );
        Navigator.of(context).pop();
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
    } catch (e) {
      setState(() => _error = 'Registration failed: $e');
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
                SizedBox(height: 12),
                Text('Create Account',
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.dark)),
                SizedBox(height: 6),
                Text('Sign up to get started',
                    style: TextStyle(fontSize: 15, color: AppColors.grey)),
                SizedBox(height: 28),
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _name,
                  icon: Icons.person_outline,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
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
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  controller: _phone,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                CustomTextField(
                  label: 'Password',
                  hint: 'Create a password',
                  controller: _password,
                  icon: Icons.lock_outline,
                  obscureText: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.grey, size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Min 6 characters' : null,
                ),
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirm,
                  icon: Icons.lock_outline,
                  obscureText: _obscure,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                Text('I am a',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.dark)),
                SizedBox(height: 8),
                Row(
                  children: [
                    _roleChip('Elder', UserRole.elder),
                    SizedBox(width: 16),
                    _roleChip('Caregiver', UserRole.caregiver),
                  ],
                ),
                if (_role == UserRole.caregiver) ...[
                  SizedBox(height: 16),
                  CustomTextField(
                    label: 'Experience',
                    hint: 'e.g. 3 years',
                    controller: _experience,
                    icon: Icons.work_history_outlined,
                  ),
                  CustomTextField(
                    label: 'Relation / Care Type',
                    hint: 'e.g. Home Nurse, Companion, Physiotherapist',
                    controller: _caregiverRelation,
                    icon: Icons.family_restroom,
                  ),
                  CustomTextField(
                    label: 'Remuneration',
                    hint: 'e.g. ৳15,000/month',
                    controller: _remuneration,
                    icon: Icons.payments_outlined,
                  ),
                ],
                if (_error != null)
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(_error!, style: TextStyle(color: AppColors.danger)),
                  ),
                SizedBox(height: 24),
                PrimaryButton(label: 'Register', onPressed: _register, loading: _loading),
                SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: TextStyle(color: AppColors.grey)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text('Login',
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

  Widget _roleChip(String label, UserRole role) {
    final selected = _role == role;
    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.primary : AppColors.grey,
            size: 20,
          ),
          SizedBox(width: 6),
          Text(label, style: TextStyle(color: AppColors.dark)),
        ],
      ),
    );
  }
}
