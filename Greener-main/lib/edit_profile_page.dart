import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String selectedOrganization = "Expense Type"; // Default dropdown value

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
          "Edit profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
        ), // 24px left & right padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            // Profile Picture
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                      'blk.png',
                    ), // Ensure the image exists
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Handle profile picture change
                    },
                    child: Text(
                      "Change photo",
                      style: TextStyle(color: Color(0xFF00BFFF), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Username Field (Disabled)
            _buildLabel("Username"),
            _buildTextField("BLK_1", isEnabled: false),

            SizedBox(height: 16),

            // Full Name Field
            _buildLabel("Full Name"),
            _buildTextField("BLK"),

            SizedBox(height: 16),

            // Email Field
            _buildLabel("Email"),
            _buildTextField("BLK@gmail.com"),

            SizedBox(height: 16),

            // Phone Number Field with Flag
            _buildLabel("Phone Number"),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFEDF1F3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Image.asset(
                      'images/flag.png',
                      width: 30,
                    ), // Country Flag
                  ),
                ),
                SizedBox(width: 8),
                Expanded(child: _buildTextField("(962) 78 666 0448")),
              ],
            ),

            SizedBox(height: 16),

            // Organization Dropdown
            _buildLabel("Location of organization"),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFEDF1F3)),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedOrganization,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down),
                  items:
                      ["Expense Type", "Organization A", "Organization B"]
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOrganization = newValue!;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 32),

            // Cancel & Done Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle Save
                  },
                  child: Text(
                    "Done",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF00BFFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  // Helper function to build text fields
  Widget _buildTextField(String hint, {bool isEnabled = true}) {
    return TextField(
      enabled: isEnabled,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isEnabled ? Colors.white : Colors.grey[200], // Disable color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFFEDF1F3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFFEDF1F3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF6E8C39)),
        ),
      ),
    );
  }
}
