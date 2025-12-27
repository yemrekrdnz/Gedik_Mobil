import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  Future<void> _updateRole(String uid, String newRole) async {
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "role": newRole,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kullanıcı Yönetimi"),
        backgroundColor: const Color.fromARGB(255, 136, 31, 96),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Kullanıcı bulunamadı"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;
              final role = data["role"] ?? "user";

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: role == "admin"
                        ? Colors.red
                        : const Color.fromARGB(255, 136, 31, 96),
                    child: Icon(
                      role == "admin" ? Icons.security : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    data["name"] ?? "İsimsiz",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(data["email"] ?? ""), Text("Rol: $role")],
                  ),
                  trailing: DropdownButton<String>(
                    value: role,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: "user", child: Text("User")),
                      DropdownMenuItem(value: "admin", child: Text("Admin")),
                    ],
                    onChanged: (val) async {
                      if (val == null || val == role) return;

                      await _updateRole(doc.id, val);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Rol güncellendi → ${data["name"]}"),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
