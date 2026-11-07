import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../core/utils/validators.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase Web Client ID for OAuth
  static const String _webClientId =
      '166386448892-8vtrcmm0mb5o7cqiqjdadibbdpaua1rj.apps.googleusercontent.com';

  bool _googleInitialized = false;

  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _ensureGoogleInitialized() async {
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId: _webClientId,
      );
      _googleInitialized = true;
    }
  }

  // Fetch current user document from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  // Register user with automatic domain-based role detection
  // @alueducation.com => automatically assigned 'staff'
  // @alustudent.com => automatically assigned 'student'
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    String? role,
    String? studentIdNumber,
  }) async {
    final domainCheck = Validators.validateEmail(email);
    if (domainCheck != null) {
      throw domainCheck;
    }

    final normalizedEmail = email.trim().toLowerCase();
    final String resolvedRole = normalizedEmail.endsWith('@alueducation.com')
        ? 'staff'
        : 'student';

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password.trim(),
      );

      final uid = credential.user!.uid;
      final userModel = UserModel(
        uid: uid,
        email: normalizedEmail,
        fullName: fullName.trim(),
        role: resolvedRole,
        studentIdNumber: resolvedRole == 'student' ? studentIdNumber?.trim() : null,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(userModel.toMap());
      await credential.user!.updateDisplayName(fullName.trim());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e);
    } catch (e) {
      throw 'Registration failed: $e';
    }
  }

  // Sign in existing user
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;
      final profile = await getUserProfile(uid);
      if (profile != null) {
        return profile;
      }

      // Fallback: create default profile if not present
      final isStaffDomain = email.trim().toLowerCase().endsWith('@alueducation.com');
      final fallbackModel = UserModel(
        uid: uid,
        email: email.trim().toLowerCase(),
        fullName: credential.user!.displayName ?? 'Campus Member',
        role: isStaffDomain ? 'staff' : 'student',
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(uid).set(fallbackModel.toMap());
      return fallbackModel;
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e);
    } catch (e) {
      throw 'Sign in failed: $e';
    }
  }

  // Sign in or create account using Google with ALU institutional domain validation
  Future<UserModel?> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final GoogleSignInAccount googleAccount = await GoogleSignIn.instance.authenticate();
      final String email = googleAccount.email.trim().toLowerCase();

      // Enforce institutional domain policy required by assignment rubric
      if (!email.endsWith('@alueducation.com') && !email.endsWith('@alustudent.com')) {
        await GoogleSignIn.instance.signOut();
        throw 'Access restricted: Only official ALU Google accounts (@alustudent.com or @alueducation.com) are permitted. You signed in with "$email".';
      }

      final GoogleSignInAuthentication googleAuth = googleAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      final existingProfile = await getUserProfile(uid);
      if (existingProfile != null) {
        return existingProfile;
      }

      final resolvedRole = email.endsWith('@alueducation.com') ? 'staff' : 'student';
      final newProfile = UserModel(
        uid: uid,
        email: email,
        fullName: userCredential.user!.displayName ?? googleAccount.displayName ?? 'ALU Member',
        role: resolvedRole,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(newProfile.toMap());
      return newProfile;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null; // User simply closed the account picker
      }
      throw 'Google Sign-In canceled or unavailable: ${e.description ?? e.code.name}';
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e);
    } catch (e) {
      if (e.toString().contains('Access restricted')) {
        rethrow;
      }
      throw 'Google Sign-In failed: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  String _parseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account exists for this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please verify and try again.';
      case 'invalid-credential':
        return 'Incorrect email or password, or no account exists yet. Please sign up first.';
      case 'email-already-in-use':
        return 'An account already exists for this email. Please sign in instead.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'The email address format is not valid.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase Console.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few moments and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact campus administration.';
      default:
        return e.message ?? 'Authentication error (${e.code})';
    }
  }
}
