import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ChangeFloorPage extends StatefulWidget {
  final int deviceNo;
  final int currentFloor;

  const ChangeFloorPage({super.key, required this.deviceNo, required this.currentFloor});

  @override
  _ChangeFloorPageState createState() => _ChangeFloorPageState();
}

class _ChangeFloorPageState extends State<ChangeFloorPage> {
  int selectedFloor = 1;

  @override
  void initState() {
    super.initState();
    selectedFloor = widget.currentFloor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Change Floor",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Device ${widget.deviceNo}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Icon(Icons.delete_sweep, color: Colors.black),
              title: Text(
                "Device No: ${widget.deviceNo}\nFloor: ${widget.currentFloor}",
              ),
              trailing: Text(
                "Change Floor",
                style: TextStyle(color: Color(0xFF00BFFF)),
              ),
            ),

            SizedBox(height: 16),

            // Dropdown for selecting floor
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFEDF1F3)),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedFloor,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down),
                  items:
                      [1, 2, 3, 4, 5]
                          .map(
                            (int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text("Floor $value"),
                            ),
                          )
                          .toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedFloor = newValue!;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6E8C39),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('devices')
                      .doc(widget.deviceNo.toString())
                      .update({
                    'floor': selectedFloor,
                  });
                  // After successful update, go back
                  Navigator.pop(context);
                } catch (e) {
                  // Show error if failed
                  print('Error updating floor: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update floor')),
                  );
                }
              },
              child: Text(
                "Done",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
