import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greener/login_page.dart';

class AdminPanelPage extends StatelessWidget {
  final String role;
  const AdminPanelPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Admin Panel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final docs =
              snapshot.data!.docs
                  .where(
                    (doc) =>
                        doc.data() is Map<String, dynamic> &&
                        (doc.data() as Map<String, dynamic>).containsKey(
                          'status',
                        ) &&
                        doc.get('status') == 'pending',
                  )
                  .toList();

          if (docs.isEmpty) {
            return Center(child: Text('No pending users.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final user = docs[index];
              final name = user.get('name');
              final email = user.get('email');
              final status = user.get('status');

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _updateUserStatus(user.id, 'approved'),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _updateUserStatus(user.id, 'rejected'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static Future<void> _updateUserStatus(String userId, String newStatus) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await docRef.update({
      'status': newStatus,
      'role': newStatus == 'approved' ? 'organization' : 'pending',
    });
  }
}
