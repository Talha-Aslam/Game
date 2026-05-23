import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'auth_api_service.dart';
import 'user_api_service.dart';

/// Authentication service
class AuthService {
  final AuthApiService _apiService = AuthApiService();
  final UserApiService _userService = UserApiService();

  UserModel? _currentUser;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  /// Fetch latest profile data
  Future<UserModel?> fetchProfile() async {
    try {
      final data = await _userService.getProfile();
      _currentUser = UserModel.fromJson(data);
      _isAuthenticated = true;
      return _currentUser;
    } catch (e) {
      _isAuthenticated = false;
      return null;
    }
  }

  /// Update user profile on backend
  Future<void> updateProfile({
    String? username,
    String? bio,
    String? title,
    String? profilePicture,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (bio != null) data['bio'] = bio;
    if (title != null) data['title'] = title;
    if (profilePicture != null) data['profile_picture'] = profilePicture;
    await _userService.updateProfile(data);
  }

  /// Upload new avatar and refresh profile
  Future<void> uploadAvatar(String filePath) async {
    final response = await _userService.uploadAvatar(filePath);
    if (response['profile_picture'] != null) {
      await fetchProfile();
    }
  }

  /// Sign in with email and password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final success = await _apiService.login(email, password);
      if (success) {
        return await fetchProfile();
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// Sign up with email and password
  Future<UserModel?> signUpWithEmail(
    String username,
    String email,
    String password,
  ) async {
    try {
      final success = await _apiService.register(username, email, password);
      if (success) {
        return await fetchProfile();
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase to get a verified token
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final idToken = await firebaseUser.getIdToken();
        if (idToken != null) {
          final success = await _apiService.googleLogin(idToken);
          if (success) {
            return await fetchProfile();
          }
        }
      }
    } catch (e) {
      // NOTE: Replace with a logging framework in production
      // print("Google Sign-In Error: $e");
      rethrow;
    }
    return null;
  }

  /// Sign in with Apple (Mocked for now)
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
    await _apiService.logout();
    _currentUser = null;
    _isAuthenticated = false;
  }

  /// Check if user is signed in
  Future<bool> checkAuthState() async {
    final loggedIn = await _apiService.isLoggedIn();
    if (loggedIn) {
      await fetchProfile();
      return _isAuthenticated;
    }
    return false;
  }
}
