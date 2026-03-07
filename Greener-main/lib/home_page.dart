import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:greener/devices_page.dart';
import 'package:greener/settings_page.dart';
import 'package:greener/statistics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greener/RewardsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String userCity = '';
  Color avatarColor = Colors.grey;

  Map<String, double> distances = {
    "organic": 100,
    "plastic": 100,
    "metal": 100,
    "paper": 100,
    "trash": 100,
  };

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    listenToRealtimeUpdates();
  }

  Future<void> fetchUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          userName = data['name'] ?? '';
          userCity = data['city'] ?? '';
          avatarColor = _generateColor(userName);
        });
      }
    }
  }

  void listenToRealtimeUpdates() {
    final db = FirebaseDatabase.instance.ref('sensor');
    db.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          distances['organic'] =
              double.tryParse(data['distance_organic'].toString()) ?? 100;
          distances['plastic'] =
              double.tryParse(data['distance_plastic'].toString()) ?? 100;
          distances['metal'] =
              double.tryParse(data['distance_metal'].toString()) ?? 100;
          distances['paper'] =
              double.tryParse(data['distance_paper'].toString()) ?? 100;
          distances['trash'] =
              double.tryParse(data['distance_trash'].toString()) ?? 100;
        });
      }
    });
  }

  double calculatePercentage(double distance) {
    if (distance <= 7.5)
      return 100;
    else if (distance <= 15)
      return 75;
    else if (distance <= 22.5)
      return 50;
    else if (distance <= 32)
      return 25;
    else
      return 0;
  }

  Color getColor(double percentage) {
    if (percentage <= 25)
      return Colors.green;
    else if (percentage <= 50)
      return Colors.yellow;
    else if (percentage <= 75)
      return Colors.orange;
    else
      return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi ${userName.isNotEmpty ? userName : '...'}",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  "Location: ${userCity.isNotEmpty ? userCity : '...'}",
                  style: TextStyle(fontSize: 18, color: Color(0xFF595959)),
                ),
              ],
            ),
            CircleAvatar(
              backgroundColor: avatarColor,
              radius: 22,
              child: Text(
                _getInitials(userName),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 1,
            color: Color(0xFFEBEBEB),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Devices",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DevicesPage()),
                    );
                  },
                  child: Text(
                    "View all",
                    style: TextStyle(fontSize: 14, color: Color(0xFF00BFFF)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              children: [_buildDeviceCard(deviceNo: 1, floor: 1)],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color(0xFF6E8C39), // هذا اللون الأخضر تبعك
        ),
        child: BottomNavigationBar(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
          currentIndex: 0,
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatisticsPage()),
              );
            }
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RewardsPage()),
              );
            }
            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: "Statistics",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              label: "Rewards",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard({required int deviceNo, required int floor}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 3,
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Device No: $deviceNo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "Floor: $floor",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCircularIndicator("organic"),
                  buildCircularIndicator("plastic"),
                  buildCircularIndicator("metal"),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 60), // فراغ لتوسيط الصف الثاني
                  buildCircularIndicator("paper"),
                  SizedBox(width: 12),
                  buildCircularIndicator("trash"),
                  SizedBox(width: 60), // فراغ يمين لتناسق الشكل
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCircularIndicator(String type) {
    double distance = distances[type] ?? 100;
    double percentage = calculatePercentage(distance);
    Color fillColor = getColor(percentage);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: percentage / 100,
                color: fillColor,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            Text(
              percentage >= 100 ? "FULL!" : "${percentage.toInt()}%",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: percentage >= 100 ? Colors.black : Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          type[0].toUpperCase() + type.substring(1),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Color _generateColor(String input) {
    return Colors.blue;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(" ").where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return "...";
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
