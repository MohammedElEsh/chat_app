import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

abstract class FirebaseAuthDataSource {
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  Stream<UserModel?> get user;
  
  UserModel? get currentUser;
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSourceImpl(this._firebaseAuth, this._firestore);

  @override
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'No user found after login',
        );
      }

      final firebaseUser = userCredential.user!;
      
      // Get user data from Firestore or create if doesn't exist
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      UserModel userModel;
      if (userDoc.exists && userDoc.data() != null) {
        // Load existing user from Firestore
        userModel = UserModel.fromMap(userDoc.data()!, firebaseUser.uid);
      } else {
        // Create new user model from Firebase Auth user
        userModel = UserModel.fromFirebaseUser(firebaseUser);
        // Save to Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).set(userModel.toMap());
      }
      
      // Update online status and last seen
      final updatedUser = userModel.markOnline();
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'isOnline': true,
        'lastSeen': Timestamp.fromDate(updatedUser.lastSeen),
      });
      
      return updatedUser;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message,
      );
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Step 1: Create Firebase Auth user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'No user found after registration',
        );
      }

      // Step 2: Update display name in Firebase Auth
      await userCredential.user!.updateDisplayName(name);
      
      // Step 3: Create UserModel with all required fields
      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        photoURL: userCredential.user!.photoURL ?? '',
        isOnline: true,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      // Step 4: Save to Firestore with all fields
      await _firestore.collection('users').doc(userModel.id).set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message,
      );
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      final currentFirebaseUser = _firebaseAuth.currentUser;
      
      // Update online status to false before signing out
      if (currentFirebaseUser != null) {
        await _firestore.collection('users').doc(currentFirebaseUser.uid).update({
          'isOnline': false,
          'lastSeen': Timestamp.fromDate(DateTime.now()),
        });
      }
      
      await _firebaseAuth.signOut();
    } catch (e) {
      throw FirebaseAuthException(
        code: 'sign-out-failed',
        message: 'Failed to sign out: ${e.toString()}',
      );
    }
  }

  @override
  Stream<UserModel?> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (userDoc.exists && userDoc.data() != null) {
        return UserModel.fromMap(userDoc.data()!, firebaseUser.uid);
      } else {
        // Fallback to creating from Firebase Auth user
        final userModel = UserModel.fromFirebaseUser(firebaseUser);
        // Save to Firestore for future use
        await _firestore.collection('users').doc(firebaseUser.uid).set(userModel.toMap());
        return userModel;
      }
    });
  }
  
  @override
  UserModel? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    
    // This is synchronous so we can't fetch from Firestore here
    // Return a basic UserModel from Firebase Auth user
    return UserModel.fromFirebaseUser(firebaseUser);
  }
}
