import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gedik_mobil/utils/firebase_errors.dart';
import '../../home/pages/home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController studentNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  String? errorMessage;

  // 📌 GOOGLE İLE GİRİŞ FONKSİYONU
  Future<void> signInWithGoogle() async {
    try {
      // 1) Google hesabı seçtir
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      // 2) Google token bilgilerini al
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3) Firebase credential oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4) Firebase giriş yap
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 5) Başarılı → HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      setState(() => errorMessage = "Google ile giriş yapılamadı: $e");
    }
  }

  // 🔥 Firebase Login (mail + şifre)
  Future<void> login() async {
    String studentNo = studentNumberController.text.trim();
    String password = passwordController.text.trim();

    if (studentNo.isEmpty || password.isEmpty) {
      setState(() => errorMessage = "Lütfen tüm alanları doldurun.");
      return;
    }

    if (studentNo.length < 8) {
      setState(() => errorMessage = "Öğrenci numarası en az 8 haneli olmalı.");
      return;
    }

    if (password.length < 4) {
      setState(() => errorMessage = "Şifre en az 4 karakter olmalı.");
      return;
    }

    try {
      String email = "$studentNo@gedik.edu.tr";

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = firebaseErrorToTurkish(e.code));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 213, 239),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LOGO
            Image.asset("assets/images/gedik.png", width: 600, height: 300),

            const SizedBox(height: 30),

            // HATA MESAJI
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    167,
                    21,
                    167,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color.fromARGB(255, 136, 31, 96),
                  ),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 136, 31, 96),
                  ),
                ),
              ),

            // Öğrenci Numarası
            TextField(
              controller: studentNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Öğrenci Numarası",
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Şifre Alanı
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Şifre",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => isPasswordVisible = !isPasswordVisible),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 📌 Giriş Yap Butonu
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 136, 31, 96),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: login,
                child: const Text(
                  "Giriş Yap",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📌 GOOGLE İLE GİRİŞ BUTONU
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                icon: Image.asset("assets/images/google.png", height: 24),
                label: const Text(
                  "Google ile Giriş Yap",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: signInWithGoogle,
              ),
            ),

            const SizedBox(height: 20),

            // Kayıt Ol Linki
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Hesabın yok mu?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Kayıt Ol",
                    style: TextStyle(
                      color: Color.fromARGB(255, 136, 31, 96),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
