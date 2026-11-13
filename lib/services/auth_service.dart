import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase Auth so screens never talk to the client
/// directly. Covers email/password plus one third-party provider (GitHub).
class AuthService {
  AuthService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Deep link the OAuth provider redirects back to on Android/iOS.
  /// Must also be added under Supabase → Authentication → URL Configuration
  /// → Redirect URLs.
  static const mobileRedirect = 'io.supabase.tesoroprint://login-callback/';

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) {
    return _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: kIsWeb ? null : mobileRedirect,
    );
  }

  /// Opens GitHub's consent page. The session arrives later through
  /// [onAuthStateChange] once the redirect comes back to the app.
  Future<bool> signInWithGitHub() {
    return _client.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: kIsWeb ? null : mobileRedirect,
      authScreenLaunchMode:
          kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}
