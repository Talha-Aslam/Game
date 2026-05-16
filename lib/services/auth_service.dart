import '../models/user_model.dart';

/// Authentication service (Firebase Auth architecture)
class AuthService {
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  /// Sign in with email and password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    // Simulate auth delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful login
    _currentUser = UserModel(
      id: 'user_001',
      username: 'ShadowKing',
      email: email,
      rankTier: 2,
      rankPoints: 3200,
      influencePoints: 15000,
      syndicateCoins: 250,
      totalGames: 142,
      wins: 89,
      losses: 53,
      familyName: 'Cobra Dynasty',
      familyRole: 'Capo',
      hasBattlePass: true,
      battlePassTier: 23,
    );
    _isAuthenticated = true;
    return _currentUser;
  }

  /// Sign up with email and password
  Future<UserModel?> signUpWithEmail(
    String username,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      email: email,
    );
    _isAuthenticated = true;
    return _currentUser;
  }

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      id: 'user_google_001',
      username: 'GooglePlayer',
      email: 'player@gmail.com',
      rankTier: 1,
      influencePoints: 5000,
    );
    _isAuthenticated = true;
    return _currentUser;
  }

  /// Sign in with Apple
  Future<UserModel?> signInWithApple() async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      id: 'user_apple_001',
      username: 'ApplePlayer',
      email: 'player@icloud.com',
      rankTier: 1,
      influencePoints: 5000,
    );
    _isAuthenticated = true;
    return _currentUser;
  }

  /// Sign out
  Future<void> signOut() async {
    _currentUser = null;
    _isAuthenticated = false;
  }

  /// Check if user is signed in
  bool checkAuthState() {
    return _isAuthenticated;
  }
}
