import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? selectedDepartment;
  String? selectedClass;
  bool isLoading = true;

  final departments = [
    "Bilgisayar Mühendisliği",
    "Yazılım Mühendisliği",
    "Makine Mühendisliği",
    "Elektrik-Elektronik Mühendisliği",
    "İşletme",
    "Psikoloji",
    "Hukuk",
    "Gastronomi",
  ];

  final classes = ["1", "2", "3", "4"];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User user = FirebaseAuth.instance.currentUser!;
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = doc.data()!;
    _nameCtrl.text = data["name"];
    _phoneCtrl.text = data["phone"];
    selectedDepartment = data["department"];
    selectedClass = data["class"];

    setState(() => isLoading = false);
  }

  Future<void> _save() async {
    if (!_phoneCtrl.text.startsWith("+90") || _phoneCtrl.text.length != 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Telefon +90XXXXXXXXXX formatında olmalı"),
        ),
      );
      return;
    }

    User user = FirebaseAuth.instance.currentUser!;

    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "name": _nameCtrl.text.trim(),
      "phone": _phoneCtrl.text.trim(),
      "department": selectedDepartment,
      "class": selectedClass,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Bilgiler güncellendi ✅")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bilgileri Düzenle"),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _input(_nameCtrl, "Ad Soyad", Icons.person),
                  _input(_phoneCtrl, "Telefon (+90XXXXXXXXXX)", Icons.phone),
                  _dropdown(
                    "Bölüm",
                    departments,
                    selectedDepartment,
                    (v) => setState(() => selectedDepartment = v),
                  ),
                  _dropdown(
                    "Sınıf",
                    classes,
                    selectedClass,
                    (v) => setState(() => selectedClass = v),
                    suffix: ". Sınıf",
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
                      ),
                      onPressed: _save,
                      child: const Text(
                        "Kaydet",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _input(TextEditingController c, String l, IconData i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: c,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: value,
        items: list
            .map((e) => DropdownMenuItem(value: e, child: Text("$e$suffix")))
            .toList(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
