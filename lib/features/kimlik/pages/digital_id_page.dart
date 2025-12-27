import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'edit_profile_page.dart';

class DigitalIDPage extends StatefulWidget {
  const DigitalIDPage({super.key});

  @override
  State<DigitalIDPage> createState() => _DigitalIDPageState();
}

class _DigitalIDPageState extends State<DigitalIDPage> {
  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  String _generateVCard(String name, String phone) {
    return '''
BEGIN:VCARD
VERSION:3.0
FN:$name
N:$name
TEL;TYPE=CELL:$phone
END:VCARD
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dijital Kimlik"),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 136, 31, 96),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Kullanıcı bilgileri bulunamadı."));
          }

          final data = snapshot.data!;
          final vCardData = _generateVCard(data["name"], data["phone"]);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🪪 KİMLİK KARTI
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 136, 31, 96),
                        Color.fromARGB(255, 180, 70, 140),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.95),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Color.fromARGB(255, 136, 31, 96),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          data["name"],
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _info(
                          Icons.confirmation_number,
                          "Öğrenci No",
                          data["studentNumber"],
                        ),
                        _divider(),
                        _info(Icons.phone, "Telefon", data["phone"]),
                        _divider(),
                        _info(Icons.school, "Bölüm", data["department"]),
                        _divider(),
                        _info(Icons.class_, "Sınıf", "${data["class"]}. Sınıf"),
                        _divider(),
                        _info(Icons.email, "Mail", data["email"]),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 📱 QR
                Column(
                  children: [
                    const Text(
                      "QR ile Rehbere Ekle",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    QrImageView(
                      data: vCardData,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔐 ŞİFRE DEĞİŞTİR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 136, 31, 96),
                    ),
                    icon: const Icon(Icons.lock, color: Colors.white),
                    label: const Text(
                      "Şifre Değiştir",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => _showChangePasswordDialog(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔐 ŞİFRE DEĞİŞTİRME DIALOG
  void _showChangePasswordDialog(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("🔐 Şifre Değiştir"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Eski Şifre"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: newCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Yeni Şifre"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Yeni Şifre (Tekrar)",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.pop(context),
                  child: const Text("İptal"),
                ),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          // 🔍 VALIDATION
                          if (oldCtrl.text.isEmpty ||
                              newCtrl.text.isEmpty ||
                              confirmCtrl.text.isEmpty) {
                            _snack(context, "Lütfen tüm alanları doldur 🙏");
                            return;
                          }

                          if (newCtrl.text.length < 6) {
                            _snack(
                              context,
                              "Yeni şifren en az 6 karakter olmalı 🔐",
                            );
                            return;
                          }

                          if (newCtrl.text != confirmCtrl.text) {
                            _snack(
                              context,
                              "Girdiğin yeni şifreler birbiriyle uyuşmuyor 🔁",
                            );
                            return;
                          }

                          try {
                            setState(() => loading = true);

                            final user = FirebaseAuth.instance.currentUser!;
                            final credential = EmailAuthProvider.credential(
                              email: user.email!,
                              password: oldCtrl.text,
                            );

                            // 🔐 RE-AUTH
                            await user.reauthenticateWithCredential(credential);

                            // 🔄 UPDATE PASSWORD
                            await user.updatePassword(newCtrl.text);

                            Navigator.pop(context);
                            _snack(context, "Şifren başarıyla güncellendi 🎉");
                          } on FirebaseAuthException catch (e) {
                            if (e.code == "wrong-password" ||
                                e.code == "invalid-credential") {
                              _snack(
                                context,
                                "Eski şifreyi yanlış girdin 😕\nLütfen tekrar kontrol et.",
                              );
                            } else if (e.code == "requires-recent-login") {
                              _snack(
                                context,
                                "Güvenliğin için tekrar giriş yapman gerekiyor 🔒",
                              );
                            } else {
                              _snack(
                                context,
                                "Şifre değiştirilemedi 😔\nLütfen biraz sonra tekrar dene.",
                              );
                            }
                          } finally {
                            setState(() => loading = false);
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Kaydet"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _info(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 136, 31, 96)),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    height: 1,
    color: Colors.black12,
  );
}
