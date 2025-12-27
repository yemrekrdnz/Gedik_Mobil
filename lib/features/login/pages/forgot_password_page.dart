import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final phoneCtrl = TextEditingController();
  final codeCtrl = TextEditingController();

  String? verificationId;
  bool codeSent = false;
  bool isLoading = false;

  void _msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> sendCode() async {
    String phone = phoneCtrl.text.trim();

    if (!phone.startsWith("+90") || phone.length != 13) {
      _msg("Telefon +90XXXXXXXXXX formatında olmalı");
      return;
    }

    setState(() => isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        _msg(e.message ?? "SMS gönderilemedi");
        setState(() => isLoading = false);
      },
      codeSent: (verId, _) {
        setState(() {
          verificationId = verId;
          codeSent = true;
          isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (verId) {
        verificationId = verId;
      },
    );
  }

  Future<void> verifyAndReset() async {
    if (verificationId == null) return;

    try {
      setState(() => isLoading = true);

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: codeCtrl.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final snap = await FirebaseFirestore.instance
          .collection("users")
          .where("phone", isEqualTo: phoneCtrl.text.trim())
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        _msg("Bu telefon numarası ile kullanıcı bulunamadı");
        return;
      }

      String email = snap.docs.first["email"];

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      _msg("Şifre sıfırlama maili gönderildi 📩");
      Navigator.pop(context);
    } catch (e) {
      _msg("Kod doğrulanamadı");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Şifremi Unuttum"),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: "Telefon (+90XXXXXXXXXX)",
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 20),

            if (!codeSent)
              ElevatedButton(
                onPressed: isLoading ? null : sendCode,
                child: const Text("SMS Gönder"),
              ),

            if (codeSent) ...[
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(
                  labelText: "SMS Kodu",
                  prefixIcon: Icon(Icons.sms),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : verifyAndReset,
                child: const Text("Doğrula & Şifre Sıfırla"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
