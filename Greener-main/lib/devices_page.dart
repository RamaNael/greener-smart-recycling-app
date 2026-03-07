import 'package:flutter/material.dart';
import 'change_floor_page.dart';

class DevicesPage extends StatefulWidget {
  DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final List<Map<String, dynamic>> devices = [
    {"id": 1, "floor": 1},
    {"id": 2, "floor": 2},
    {"id": 3, "floor": 2},
  ];

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
          "Devices",
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
          children:
              devices
                  .map(
                    (device) => _buildDeviceItem(
                      context,
                      device["id"],
                      device["floor"],
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildDeviceItem(BuildContext context, int deviceNo, int floor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Device $deviceNo",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ListTile(
          leading: Icon(Icons.delete_sweep, color: Colors.black),
          title: Text("Device No: $deviceNo\nFloor: $floor"),
          trailing: TextButton(
            onPressed: () {
              _showFloorDialog(context, deviceNo, floor);
            },
            child: Text(
              "Change Floor",
              style: TextStyle(color: Color(0xFF00BFFF)),
            ),
          ),
        ),
        Divider(),
      ],
    );
  }

  void _showFloorDialog(BuildContext context, int deviceNo, int currentFloor) {
    String selectedFloor = "Floor $currentFloor";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(24),
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Device $deviceNo",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.black),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Device No: $deviceNo"),
                        Text("Floor: $currentFloor"),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),

                /// Updated Dropdown with white background and black border
                DropdownButtonFormField<String>(
                  value: selectedFloor,
                  dropdownColor: Colors.white, // ✅ White popup background
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.black,
                      ), // ✅ Black border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  items:
                      ["Floor 1", "Floor 2", "Floor 3"]
                          .map(
                            (floor) => DropdownMenuItem(
                              value: floor,
                              child: Text(floor),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFloor = value!;
                      int floorNumber =
                          int.tryParse(value.split(" ").last) ?? currentFloor;
                      devices[deviceNo - 1]["floor"] = floorNumber;
                    });
                  },
                ),
                SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6E8C39),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
