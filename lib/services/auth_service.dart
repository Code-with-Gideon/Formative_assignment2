import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/utils/validators.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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

  Future<void> signOut() async {
    await _auth.signOut();
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
