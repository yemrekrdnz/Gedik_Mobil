import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gedik_mobil/utils/firebase_errors.dart';
import 'package:gedik_mobil/services/auth_service.dart';
import 'package:gedik_mobil/models/user_role.dart';
import '../../home/pages/home_page.dart';
import 'package:gedik_mobil/admin/pages/admin_panel.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController studentNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isPasswordVisible = false;
  String? errorMessage;
  bool isLoading = false;

  Future<void> _navigateBasedOnRole(String uid) async {
    UserRole role = await _authService.getUserRole(uid);

    if (role == UserRole.admin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanel()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

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

    setState(() => isLoading = true);

    try {
      String email = "$studentNo@gedik.edu.tr";

      UserCredential userCredential = await _authService
          .signInWithEmailAndPassword(email, password);

      await _navigateBasedOnRole(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = firebaseErrorToTurkish(e.code));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 213, 239),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          children: [
            Image.asset("assets/images/gedik.png", width: 600, height: 300),
            const SizedBox(height: 30),

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

            // 🔐 ŞİFREMİ UNUTTUM
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordPage(),
                    ),
                  );
                },
                child: const Text(
                  "Şifremi Unuttum",
                  style: TextStyle(
                    color: Color.fromARGB(255, 136, 31, 96),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

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
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text(
                        "Giriş Yap",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Hesabın yok mu?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
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
