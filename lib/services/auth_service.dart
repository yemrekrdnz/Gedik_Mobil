import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Kullanıcı rolünü kontrol et
  Future<AppUser?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Kullanıcı verisi alınamadı: $e');
      return null;
    }
  }

  // Kullanıcı rolünü al
  Future<UserRole> getUserRole(String uid) async {
    try {
      AppUser? user = await getUserData(uid);
      return user?.role ?? UserRole.student;
    } catch (e) {
      print('Rol alınamadı: $e');
      return UserRole.student;
    }
  }

  // Admin kontrolü
  Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    UserRole role = await getUserRole(currentUser!.uid);
    return role == UserRole.admin;
  }

  // Email/Şifre ile giriş
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Google ile giriş
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    // Google ile ilk girişte kullanıcı oluştur
    await _createUserIfNotExists(
      userCredential.user!.uid,
      userCredential.user!.email!,
      userCredential.user!.displayName ?? '',
      'Google Kullanıcı',
      UserRole.student,
    );

    return userCredential;
  }

  // Kayıt ol
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    String studentNumber,
  ) async {
    UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Kullanıcı verisini Firestore'a kaydet
    await _createUserIfNotExists(
      userCredential.user!.uid,
      email,
      name,
      studentNumber,
      UserRole.student,
    );

    return userCredential;
  }

  // Kullanıcıyı Firestore'da oluştur (yoksa)
  Future<void> _createUserIfNotExists(
    String uid,
    String email,
    String name,
    String studentNumber,
    UserRole role,
  ) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      AppUser newUser = AppUser(
        uid: uid,
        email: email,
        name: name,
        studentNumber: studentNumber,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(newUser.toFirestore());
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      // Only sign out from Google if user signed in with Google
      final user = _auth.currentUser;
      if (user != null) {
        final isGoogleUser = user.providerData.any(
          (info) => info.providerId == 'google.com',
        );
        
        if (isGoogleUser) {
          try {
            await GoogleSignIn().signOut();
          } catch (e) {
            // Google signout not configured for web, skip
          }
        }
      }
      
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Kullanıcı rolünü güncelle (sadece admin yetkili kişiler için)
  Future<void> updateUserRole(String uid, UserRole newRole) async {
    await _firestore.collection('users').doc(uid).update({
      'role': newRole.value,
    });
  }
}
