import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/app_user.dart';

class AuthService {
  final _client = supabase;

  User? get currentAuthUser => _client.auth.currentUser;
  bool get isLoggedIn => currentAuthUser != null;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? experience,
    String? caregiverRelation,
    String? remuneration,
  }) async {
    // full_name / phone / role are passed as auth user metadata. A DB
    // trigger (see supabase/schema.sql) reads this metadata and creates
    // the matching public.profiles row server-side — this works even
    // when "Confirm email" is on and there's no active session yet.
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
        'role': role == UserRole.caregiver ? 'caregiver' : 'elder',
      },
    );

    // Best-effort: if we do have a session already (email confirmation
    // off), make sure the profile row exists / is up to date right away
    // instead of waiting on trigger replication. This is also the only
    // place the caregiver directory fields (experience/relation/
    // remuneration) get saved at sign-up — if there's no session yet
    // (email confirmation required) the caregiver can fill these in
    // later from Profile > Edit.
    final user = response.user;
    if (user != null && _client.auth.currentSession != null) {
      try {
        await _client.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'role': role == UserRole.caregiver ? 'caregiver' : 'elder',
          if (role == UserRole.caregiver) 'experience': experience,
          if (role == UserRole.caregiver) 'caregiver_relation': caregiverRelation,
          if (role == UserRole.caregiver) 'remuneration': remuneration,
        });
      } catch (_) {
        // Non-fatal — the trigger will have already created the row.
      }
    }
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<AppUser?> fetchProfile() async {
    final uid = currentAuthUser?.id;
    if (uid == null) return null;
    final data = await _client.from('profiles').select().eq('id', uid).maybeSingle();
    if (data == null) return null;
    return AppUser.fromMap(data);
  }

  Future<void> updateProfile(AppUser user) async {
    await _client.from('profiles').update(user.toMap()).eq('id', user.id);
  }

  Future<void> resetPassword(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }
}
