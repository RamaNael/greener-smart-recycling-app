import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:greener/RewardsPage.dart';
import 'package:greener/settings_page.dart';
import 'package:greener/home_page.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  Map<String, int> imageCount = {
    'Plastic': 0,
    'Metal': 0,
    'Trash': 0,
    'Paper': 0,
    'Organic': 0,
  };

  int totalImages = 0;
  int selectedTab = 0;
  final List<String> tabs = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  StreamSubscription<DatabaseEvent>? statisticsSubscription;

  @override
  void initState() {
    super.initState();
    listenToImageCounts();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    statisticsSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void listenToImageCounts() {
    final ref = FirebaseDatabase.instance.ref("statistics");
    statisticsSubscription = ref.onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          imageCount = {
            'Plastic': data['plastic'] ?? 0,
            'Metal': data['metal'] ?? 0,
            'Trash': data['trash'] ?? 0,
            'Paper': data['paper'] ?? 0,
            'Organic': data['organic'] ?? 0,
          };
          totalImages = imageCount.values.reduce((a, b) => a + b);
        });
      }
    });
  }

  double getPercentage(String category) {
    if (totalImages == 0) return 0;
    return (imageCount[category]! / totalImages) * 100;
  }

  List<PieChartSectionData> getPieChartSections() {
    final colors = {
      'Plastic': Colors.deepOrange,
      'Paper': Colors.yellow,
      'Metal': Colors.deepPurple,
      'Trash': Colors.teal,
      'Organic': Colors.green,
    };

    return imageCount.entries.map((entry) {
      return PieChartSectionData(
        color: colors[entry.key],
        value: entry.value.toDouble(),
        title: '',
        radius: 27,
      );
    }).toList();
  }

  Widget buildLegend() {
    final colors = {
      'Trash': Colors.teal,
      'Metal': Colors.deepPurple,
      'Paper': Colors.yellow,
      'Plastic': Colors.deepOrange,
      'Organic': Colors.green,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          colors.keys.map((key) {
            return Row(
              children: [
                Container(width: 12, height: 12, color: colors[key]),
                SizedBox(width: 4),
                Text(
                  "$key\n${getPercentage(key).toStringAsFixed(1)}%",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            );
          }).toList(),
    );
  }

  Widget buildDeviceCards() {
    List<Map<String, dynamic>> devices = [
      {'name': 'Device 3', 'count': 230},
      {'name': 'All Devices', 'count': totalImages},
      {'name': 'Device 1', 'count': 500},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children:
            devices.map((device) {
              bool isAll = device['name'] == 'All Devices';
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 6),
                padding: EdgeInsets.all(16),
                width: 130,
                decoration: BoxDecoration(
                  color: isAll ? Color(0xFF83914C) : Color(0xFFE1E6CF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      device['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isAll ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Total\ninteractions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isAll ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      device['count'].toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isAll ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = totalImages == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color(0xFF6E8C39), // هذا اللون الأخضر تبعك
        ),
        child: BottomNavigationBar(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Title
              Text('Statistics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),

              // Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(tabs.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(tabs[index]),
                      selected: selectedTab == index,
                      selectedColor: Color(0xFF83914C),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selectedTab == index ? Colors.white : Colors.black,
                      ),
                      checkmarkColor: Colors.white,
                      onSelected: (_) {
                        setState(() {
                          selectedTab = index;
                          _controller.forward(from: 0);
                        });
                      },
                    ),
                  );
                }),
              ),

              SizedBox(height: 20),

              // Spacer pushes pie chart to middle
              Spacer(),

              // Pie Chart in center
              if (isLoading)
                CircularProgressIndicator()
              else
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 170,
                        width: 170,
                        child: PieChart(
                          PieChartData(
                            sections: getPieChartSections(),
                            centerSpaceRadius: 107,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text('All Devices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                          Text('$totalImages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                          Text('Total interactions', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),

              Spacer(),

              // Legend
              if (!isLoading) buildLegend(),

              SizedBox(height: 20),

              // Device cards at bottom
              if (!isLoading) buildDeviceCards(),

              SizedBox(height: 20), // not too close to navigation bar
            ],
          ),

        ),
      ),
    );
  }
}
