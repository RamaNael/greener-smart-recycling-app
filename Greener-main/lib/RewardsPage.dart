// Your original imports
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';

import 'package:greener/home_page.dart';
import 'package:greener/settings_page.dart';
import 'package:greener/statistics.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  File? _selectedImage;
  final _nameController = TextEditingController();
  final _pointsController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedType;
  final List<String> _rewardTypes = ['Discount', 'Free Item', 'Voucher'];
  List<Map<String, dynamic>> _rewards = [];

  @override
  void initState() {
    super.initState();
    _fetchRewards();
  }

  void _fetchRewards() {
    final ref = FirebaseDatabase.instance.ref('rewards');
    ref.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final temp = data.entries.map((e) {
          final reward = Map<String, dynamic>.from(e.value);
          reward['id'] = e.key;
          return reward;
        }).toList();
        setState(() => _rewards = temp);
      }
    });
  }

  Future<void> _submitReward() async {
    final name = _nameController.text.trim();
    final points = _pointsController.text.trim();
    final location = _locationController.text.trim();
    final type = _selectedType;

    if (_selectedImage == null || name.isEmpty || points.isEmpty || type == null || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields and select an image."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance.ref('rewards/$fileName.jpg');
    await storageRef.putFile(_selectedImage!);
    final imageUrl = await storageRef.getDownloadURL();

    final newReward = {
      'name': name,
      'points': int.parse(points),
      'imageUrl': imageUrl,
      'type': type,
      'location': location,
      'redemptions': 0,
    };

    await FirebaseDatabase.instance.ref('rewards').push().set(newReward);

    _nameController.clear();
    _pointsController.clear();
    _locationController.clear();
    setState(() {
      _selectedType = null;
      _selectedImage = null;
    });
  }

  void _confirmDelete(String rewardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // White background
        title: Text('Confirm Deletion', style: TextStyle(color: Colors.black)),
        content: Text('Are you sure you want to delete this reward?', style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF333333), // Text color
              backgroundColor: Colors.white, // No purple background on click
              splashFactory: NoSplash.splashFactory, // No ripple
            ),
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.white,
              splashFactory: NoSplash.splashFactory,
            ),
            child: Text('Delete'),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseDatabase.instance.ref('rewards/$rewardId').remove();
            },
          ),
        ],
      ),
    );
  }

  void _editReward(Map<String, dynamic> reward) {
    _nameController.text = reward['name'];
    _pointsController.text = reward['points'].toString();
    _locationController.text = reward['location'];
    _selectedType = reward['type'];
    _selectedImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF6E8C39)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Image.network(reward['imageUrl'], fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField("Name", _nameController),
              const SizedBox(height: 12),
              _buildTextField("Points Required", _pointsController, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: _rewardTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (val) => setState(() => _selectedType = val),
                decoration: InputDecoration(
                  labelText: "Reward Type",
                  labelStyle: TextStyle(color: Color(0xFF333333)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF6E8C39)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF6E8C39), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField("Location", _locationController),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6E8C39),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  Navigator.pop(context);

                  final updatedReward = {
                    'name': _nameController.text.trim(),
                    'points': int.parse(_pointsController.text.trim()),
                    'type': _selectedType,
                    'location': _locationController.text.trim(),
                    'redemptions': reward['redemptions'],
                    'imageUrl': reward['imageUrl'],
                  };

                  if (_selectedImage != null) {
                    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
                    final storageRef = FirebaseStorage.instance.ref('rewards/$fileName.jpg');
                    await storageRef.putFile(_selectedImage!);
                    final imageUrl = await storageRef.getDownloadURL();
                    updatedReward['imageUrl'] = imageUrl;
                  }

                  await FirebaseDatabase.instance.ref('rewards/${reward['id']}').set(updatedReward);

                  _nameController.clear();
                  _pointsController.clear();
                  _locationController.clear();
                  setState(() {
                    _selectedType = null;
                    _selectedImage = null;
                  });
                },
                child: const Text("Update Reward", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddRewardSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF6E8C39)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField("Name", _nameController),
              const SizedBox(height: 12),
              _buildTextField("Points Required", _pointsController, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: _rewardTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (val) => setState(() => _selectedType = val),
                decoration: InputDecoration(
                  labelText: "Reward Type",
                  labelStyle: TextStyle(color: Color(0xFF333333)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF6E8C39)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF6E8C39), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField("Location", _locationController),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6E8C39),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _submitReward,
                child: const Text("Add Reward", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: Color(0xFF6E8C39),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF333333)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF6E8C39)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF6E8C39), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Rewards",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 4),
            Text(
              "Manage your organization rewards",
              style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6)),
            ),
          ],
        ),
      ),

      body: _rewards.isEmpty
          ? const Center(
        child: Text("No rewards yet!", style: TextStyle(fontSize: 18, color: Colors.grey)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rewards.length,
        itemBuilder: (context, index) {
          final reward = _rewards[index];
          return Dismissible(
            key: Key(reward['id']),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white, size: 30),
            ),
            confirmDismiss: (direction) async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Deletion'),
                  content: Text('Are you sure you want to delete this reward?'),
                  actions: [
                    TextButton(
                      child: Text('Cancel', style: TextStyle(color: Colors.black)),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    TextButton(
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await FirebaseDatabase.instance.ref('rewards/${reward['id']}').remove();
              }
              return confirm ?? false;
            },
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Color(0xFF6E8C39).withOpacity(0.3), width: 1),
              ),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        reward['imageUrl'],
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),

                    // TEXTS (EXPANDED)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reward['name'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${reward['redemptions']} redemptions",
                            style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.6)),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Points: ${reward['points']} pts",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // BUTTONS (VERTICAL)
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.black, size: 20),
                          onPressed: () => _editReward(reward),
                          tooltip: "Edit",
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _confirmDelete(reward['id']),
                          tooltip: "Delete",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),


          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRewardSheet,
        backgroundColor: const Color(0xFF6E8C39),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: const Color(0xFF6E8C39)),
        child: BottomNavigationBar(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
            }
            if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsPage()));
            }
            if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Statistics"),
            BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: "Rewards"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}
