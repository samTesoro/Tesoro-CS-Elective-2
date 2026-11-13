import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

/// Exposes the signed-in user to the widget tree and notifies listeners
/// (including GoRouter's redirect) whenever the auth state changes.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _user = _service.currentUser;
    _sub = _service.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  final AuthService _service;
  late final StreamSubscription<AuthState> _sub;

  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  Future<bool> signIn(String email, String password) =>
      _run(() => _service.signInWithEmail(email, password));

  /// Returns true on success. If email confirmation is on in Supabase,
  /// the user has to confirm before a session exists.
  Future<bool> signUp(String email, String password) =>
      _run(() => _service.signUpWithEmail(email, password));

  Future<bool> signInWithGitHub() => _run(_service.signInWithGitHub);

  Future<void> signOut() => _run(_service.signOut);

  Future<bool> _run(Future<Object?> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      debugPrint('Auth error: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
