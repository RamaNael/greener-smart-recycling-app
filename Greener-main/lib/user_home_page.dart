import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greener/login_page.dart';
import 'package:greener/UserRewardsPage.dart';

class UserPage extends StatefulWidget {
  final String userId;

  const UserPage({required this.userId, Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isStarted = false;
  int userPoints = 0;
  StreamSubscription<DatabaseEvent>? wasteListener;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _listenToWasteChanges();
  }

  @override
  void dispose() {
    wasteListener?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        isStarted = data['started'] ?? false;
        userPoints = data['points'] ?? 0;
      });
    }
  }

  Future<void> _toggleStartStop() async {
    final newState = !isStarted;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'started': newState});

    final dbRef = FirebaseDatabase.instance.ref("active_user");

    if (newState) {
      await dbRef.set({'id': widget.userId});
    } else {
      await dbRef.remove();
    }

    setState(() {
      isStarted = newState;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newState
              ? 'Started! Points will now be counted.'
              : 'Stopped. No more points will be added.',
        ),
        backgroundColor: newState ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _listenToWasteChanges() {
    final wasteRef = FirebaseDatabase.instance.ref(
      "users_waste/${widget.userId}/lastWaste",
    );

    wasteListener = wasteRef.onValue.listen((DatabaseEvent event) async {
      final data = event.snapshot.value;
      if (data == null) {
        print("⚠️ No waste data");
        return;
      }

      final String newWaste = data.toString().toLowerCase();
      print("🔥 Detected new waste: $newWaste");

      // 🕒 Check user_logs for last entry
      final logsRef = FirebaseDatabase.instance.ref(
        "user_logs/${widget.userId}",
      );
      final lastLogSnapshot = await logsRef.orderByKey().limitToLast(1).get();

      if (lastLogSnapshot.exists) {
        final lastLog = (lastLogSnapshot.value as Map).values.first;
        final lastType = lastLog["type"]?.toString().toLowerCase();
        final lastTime = DateTime.tryParse(lastLog["timestamp"] ?? "");
      }

      // ✅ Update statistics
      final statsRef = FirebaseDatabase.instance.ref("statistics/$newWaste");
      final current = await statsRef.get();
      final int count = int.tryParse(current.value.toString()) ?? 0;
      await statsRef.set(count + 1);
      print("✅ Updated statistics for $newWaste to ${count + 1}");

      // ✅ Update user_logs
      final logEntryRef = logsRef.push();
      await logEntryRef.set({
        "type": newWaste,
        "timestamp": DateTime.now().toIso8601String(),
      });

      // ✅ Add point if user is started
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get();

      final userData = userDoc.data();
      if (userData != null && userData['started'] == true) {
        final newPoints = (userData['points'] ?? 0) + 1;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({'points': newPoints});

        setState(() {
          userPoints = newPoints;
        });

        print("🏆 Point added! Total: $newPoints");
        _showWasteAnimation(newWaste);
      } else {
        print("🛑 User not in START mode. No point added.");
      }
    });
  }

  void _showWasteAnimation(String wasteType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.recycling, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              "You got a point for: $wasteType",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⬅️ تحت الـ Scaffold في build:
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "User Dashboard",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Your Points: $userPoints",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: _toggleStartStop,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isStarted ? Colors.red : Colors.green,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isStarted ? 'Stop' : 'Start',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () async {
                    // 🔥 حذف آخر قيمة نفاية
                    await FirebaseDatabase.instance
                        .ref("users_waste/${widget.userId}/lastWaste")
                        .remove();

                    // 🔥 تسجيل الخروج
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // ✅ ⬇️ BottomNavigationBar
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: const Color(0xFF6E8C39)),
        child: BottomNavigationBar(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
          currentIndex: 0, // حاليا احنا عال User Dashboard
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => UserRewardsPage(
                        userId: widget.userId,
                      ), // الصفحة اللي حنجهزها بعدين
                ),
              );
            }
            if (index == 0) {
              // انت اصلا بالصفحة
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              label: "Rewards",
            ),
          ],
        ),
      ),
    );
  }
}
