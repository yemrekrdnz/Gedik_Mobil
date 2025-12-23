import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gedik_mobil/features/login/pages/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController studentNoCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();

  String? errorMessage;
  bool showPassword = false;
  bool showConfirmPassword = false;

  String? selectedDepartment;
  String? selectedClass;

  final List<String> departmentList = [
    "Bilgisayar Mühendisliği",
    "Yazılım Mühendisliği",
    "Makine Mühendisliği",
    "Elektrik-Elektronik Mühendisliği",
    "İşletme",
    "Psikoloji",
    "Hukuk",
    "Gastronomi",
  ];

  final List<String> classList = ["1", "2", "3", "4"];

  // 🎉 KAYIT BAŞARILI POPUP
  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("🎉 Kayıt Başarılı"),
          content: const Text("Hesabınız oluşturuldu, giriş yapabilirsiniz."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text("Tamam"),
            ),
          ],
        );
      },
    );
  }

  // 🔥 FIREBASE SIGNUP + FIRESTORE KAYIT
  Future<void> signUp() async {
    String studentNo = studentNoCtrl.text.trim();
    String password = passwordCtrl.text.trim();
    String confirmPassword = confirmPasswordCtrl.text.trim();
    String fullName = nameCtrl.text.trim();

    // VALIDATION
    if (studentNo.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        fullName.isEmpty ||
        selectedDepartment == null ||
        selectedClass == null) {
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

    if (password != confirmPassword) {
      setState(() => errorMessage = "Şifreler eşleşmiyor.");
      return;
    }

    try {
      String email = "$studentNo@gedik.edu.tr";

      // 🔥 Firebase Authentication: kullanıcı oluştur
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 🔥 Firestore: ek bilgiler kaydedilir
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .set({
            "name": fullName,
            "email": email,
            "studentNumber": studentNo,
            "department": selectedDepartment,
            "class": selectedClass,
            "createdAt": DateTime.now(),
          });

      // 🔥 Otomatik login'i kapatmak için çıkış yap
      await FirebaseAuth.instance.signOut();

      // 🎉 Popup aç
      showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "Kayıt sırasında hata oluştu.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 213, 239),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        title: const Text("Kayıt Ol"),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // AD SOYAD
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Ad Soyad",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ÖĞRENCİ NO
            TextField(
              controller: studentNoCtrl,
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

            // BÖLÜM
            DropdownButtonFormField<String>(
              value: selectedDepartment,
              items: departmentList
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              decoration: InputDecoration(
                labelText: "Bölüm",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) => setState(() => selectedDepartment = val),
            ),
            const SizedBox(height: 20),

            // SINIF
            DropdownButtonFormField<String>(
              value: selectedClass,
              items: classList
                  .map(
                    (c) => DropdownMenuItem(value: c, child: Text("$c. Sınıf")),
                  )
                  .toList(),
              decoration: InputDecoration(
                labelText: "Sınıf",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) => setState(() => selectedClass = val),
            ),
            const SizedBox(height: 20),

            // ŞİFRE
            TextField(
              controller: passwordCtrl,
              obscureText: !showPassword,
              decoration: InputDecoration(
                labelText: "Şifre",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => showPassword = !showPassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ŞİFRE TEKRAR
            TextField(
              controller: confirmPasswordCtrl,
              obscureText: !showConfirmPassword,
              decoration: InputDecoration(
                labelText: "Şifre Tekrar",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () => setState(
                    () => showConfirmPassword = !showConfirmPassword,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // BUTON
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
                onPressed: signUp,
                child: const Text(
                  "Kayıt Ol",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
