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
  final TextEditingController phoneCtrl = TextEditingController();

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

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("🎉 Kayıt Başarılı"),
        content: const Text("Hesabınız oluşturuldu, giriş yapabilirsiniz."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  Future<void> signUp() async {
    String studentNo = studentNoCtrl.text.trim();
    String password = passwordCtrl.text.trim();
    String confirmPassword = confirmPasswordCtrl.text.trim();
    String fullName = nameCtrl.text.trim();
    String phone = phoneCtrl.text.trim();

    if (studentNo.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        fullName.isEmpty ||
        phone.isEmpty ||
        selectedDepartment == null ||
        selectedClass == null) {
      setState(() => errorMessage = "Lütfen tüm alanları doldurun.");
      return;
    }

    if (!phone.startsWith("+90") || phone.length != 13) {
      setState(
        () =>
            errorMessage = "Telefon numarası +90XXXXXXXXXX formatında olmalı.",
      );
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

      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .set({
            "name": fullName,
            "email": email,
            "studentNumber": studentNo,
            "phone": phone,
            "department": selectedDepartment,
            "class": selectedClass,
            "createdAt": DateTime.now(),
            "role": "user",
          });

      await FirebaseAuth.instance.signOut();
      showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      setState(
        () => errorMessage = e.message ?? "Kayıt sırasında hata oluştu.",
      );
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

            _input(nameCtrl, "Ad Soyad", Icons.person),
            _input(
              studentNoCtrl,
              "Öğrenci Numarası",
              Icons.numbers,
              isNumber: true,
            ),
            _input(
              phoneCtrl,
              "Telefon (+90XXXXXXXXXX)",
              Icons.phone,
              isPhone: true,
            ),

            const SizedBox(height: 20),
            _dropdown(
              "Bölüm",
              departmentList,
              selectedDepartment,
              (v) => setState(() => selectedDepartment = v),
            ),
            const SizedBox(height: 20),
            _dropdown(
              "Sınıf",
              classList,
              selectedClass,
              (v) => setState(() => selectedClass = v),
              suffix: ". Sınıf",
            ),

            const SizedBox(height: 20),
            _passwordField(
              passwordCtrl,
              "Şifre",
              showPassword,
              () => setState(() => showPassword = !showPassword),
            ),
            const SizedBox(height: 20),
            _passwordField(
              confirmPasswordCtrl,
              "Şifre Tekrar",
              showConfirmPassword,
              () => setState(() => showConfirmPassword = !showConfirmPassword),
            ),

            const SizedBox(height: 30),
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

  Widget _input(
    TextEditingController c,
    String l,
    IconData i, {
    bool isNumber = false,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: c,
        keyboardType: isNumber || isPhone
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: l,
          prefixIcon: Icon(i),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<String> list,
    String? value,
    Function(String?) onChanged, {
    String suffix = "",
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: list
          .map((e) => DropdownMenuItem(value: e, child: Text("$e$suffix")))
          .toList(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: onChanged,
    );
  }

  Widget _passwordField(
    TextEditingController c,
    String l,
    bool show,
    VoidCallback toggle,
  ) {
    return TextField(
      controller: c,
      obscureText: !show,
      decoration: InputDecoration(
        labelText: l,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(show ? Icons.visibility : Icons.visibility_off),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
