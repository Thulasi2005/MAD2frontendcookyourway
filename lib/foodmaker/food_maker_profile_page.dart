import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodMakerProfilePage extends StatefulWidget {
  final String identifier; // Food maker's full name
  final String token; // Authentication token

  FoodMakerProfilePage({required this.identifier, required this.token});

  @override
  _FoodMakerProfilePageState createState() => _FoodMakerProfilePageState();
}

class _FoodMakerProfilePageState extends State<FoodMakerProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  File? _profileImage; // To hold the selected image
  String _email = ''; // To hold the fetched email
  String _phone = ''; // To hold the fetched phone number
  String _address = ''; // To hold the fetched address
  String _ordersReceived = ''; // To hold the number of orders received
  String _ordersPrepared = ''; // To hold the number of orders prepared
  String _paymentsReceived = ''; // To hold the number of payments received
  String _revenueEarned = ''; // To hold the total revenue earned
  bool _isLoading = true; // Loading state
  bool _isDarkMode = false; // To track dark mode state

  @override
  void initState() {
    super.initState();
    print('Identifier passed: ${widget.identifier}');

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    // Fetch food maker profile details
    _fetchFoodMakerProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Function to toggle dark mode
  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path); // Set the selected image
      });
    }
  }

  // Function to fetch food maker profile data from the backend
  Future<void> _fetchFoodMakerProfile() async {
    final url = 'http://192.168.1.26:8000/api/get_food_maker_profile?identifier=${Uri.encodeComponent(widget.identifier)}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}', // Pass the token if needed
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _email = data['email'];
        _phone = data['phone'];
        _address = data['address'];
        _ordersReceived = data['orders_received'].toString();
        _ordersPrepared = data['orders_prepared'].toString();
        _paymentsReceived = data['payments_received'].toString();
        _revenueEarned = data['revenue_earned'].toString();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching food maker profile: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Maker Profile', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
        backgroundColor: _isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: _isDarkMode ? Colors.white : Colors.black),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode, color: _isDarkMode ? Colors.white : Colors.black),
            onPressed: _toggleDarkMode, // Toggle dark mode
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage, // Allow image upload on tap
              child: FadeTransition(
                opacity: _animation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60.0,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : AssetImage('assets/images/logo.png') as ImageProvider,
                      backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent,
                        ),
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.identifier,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.lightGreen[100] : Colors.lightGreen[900],
              ),
            ),
            SizedBox(height: 30),
            _buildProfileInfo('Email', _email.isNotEmpty ? _email : 'N/A'),
            _buildProfileInfo('Phone', _phone.isNotEmpty ? _phone : 'N/A'),
            _buildProfileInfo('Address', _address.isNotEmpty ? _address : 'N/A'),
            _buildProfileInfo('Orders Received', _ordersReceived.isNotEmpty ? _ordersReceived : '0'),
            _buildProfileInfo('Orders Prepared', _ordersPrepared.isNotEmpty ? _ordersPrepared : '0'),
            _buildProfileInfo('Payments Received', _paymentsReceived.isNotEmpty ? _paymentsReceived : '0'),
            _buildProfileInfo('Revenue Earned', _revenueEarned.isNotEmpty ? _revenueEarned : '0'),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                _logoutFoodMaker(context); // Call the logout function
              },
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
    );
  }

  // Helper function to build profile information row
  Widget _buildProfileInfo(String label, String value) {
    return Card(
      color: _isDarkMode ? Colors.grey[850] : Colors.white,
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16.0,
                  color: _isDarkMode ? Colors.white60 : Colors.black54,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to handle food maker logout
  void _logoutFoodMaker(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/loginselection');
  }
}
