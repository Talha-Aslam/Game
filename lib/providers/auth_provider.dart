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

  AuthState copyWith({AuthStatus? status, UserModel? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.error, errorMessage: 'Invalid credentials');
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signUpWithEmail(String username, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.signUpWithEmail(username, email, password);
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
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});
