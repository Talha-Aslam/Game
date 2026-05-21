import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  static const Set<String> _reservedUsernames = {
    'admin',
    'moderator',
    'support',
    'system',
    'shadowking',
    'googleplayer',
    'appleplayer',
    'ghostboss',
    'nightviper',
  };

  @override
  AuthState build() => const AuthState();

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final isLoggedIn = await _authService.checkAuthState();
      if (isLoggedIn && _authService.currentUser != null) {
        state = AuthState(status: AuthStatus.authenticated, user: _authService.currentUser);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Invalid credentials',
        );
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signUpWithEmail(
    String username,
    String email,
    String password,
  ) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.signUpWithEmail(
        username,
        email,
        password,
      );
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.signInWithApple();
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> isUsernameAvailable(String username) async {
    final currentUser = state.user;
    if (currentUser == null) return false;

    final normalized = username.trim().toLowerCase();
    final currentNormalized = currentUser.username.trim().toLowerCase();

    if (normalized.isEmpty) return false;
    if (normalized == currentNormalized) return true;

    // Mock availability check until backend is connected.
    await Future.delayed(const Duration(milliseconds: 350));
    return !_reservedUsernames.contains(normalized);
  }

  Future<String?> updateProfileInfo({
    required String username,
    required String tagline,
  }) async {
    final currentUser = state.user;
    if (currentUser == null) return 'You are not logged in.';

    final cleanUsername = username.trim();
    final cleanTagline = tagline.trim();

    if (cleanUsername.length < 3 || cleanUsername.length > 20) {
      return 'Username must be between 3 and 20 characters.';
    }

    try {
      // Call backend to update profile
      await _authService.updateProfile(
        username: cleanUsername,
        bio: cleanTagline,
      );

      // Refresh the profile from backend
      final refreshedUser = await _authService.fetchProfile();
      if (refreshedUser != null) {
        state = state.copyWith(user: refreshedUser);
      }
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});
