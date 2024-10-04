import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerProfilePage extends StatefulWidget {
  final String identifier;
  final String token;

  CustomerProfilePage({required this.identifier, required this.token});

  @override
  _CustomerProfilePageState createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  File? _profileImage;
  String _fullName = '';
  String _loyaltyPoints = '';
  bool _isLoading = true;
  bool _isDarkMode = false; // Add a variable for dark mode
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 2; // Initialize to Profile tab

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _fetchUserProfile();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _fetchUserProfile() async {
    final url = 'http://10.0.2.2/get_customer_profile';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _fullName = data['full_name'] ?? 'No Name';
          _loyaltyPoints = data['loyalty_points']?.toString() ?? '0';
          _isLoading = false;
        });
      } else {
        _handleError(response.statusCode);
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch user profile: $e');
    }
  }

  void _handleError(int statusCode) {
    setState(() {
      _isLoading = false;
    });
    print('Error fetching user profile: $statusCode');
    _showErrorDialog('Error: $statusCode. Please try again.');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on the selected index
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/customerhomepage');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/customercustomizedresponse');
        break;
      case 2:
      // Profile already selected, do nothing
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/help');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Profile'),
        backgroundColor: Color(0xFF4CAF50),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode; // Toggle dark mode
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center( // Center everything
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: FadeTransition(
                  opacity: _animation,
                  child: Container( // Box for profile image
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 60.0,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : AssetImage('assets/images/logo.png')
                      as ImageProvider,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container( // Box for full name
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _fullName.isNotEmpty ? _fullName : widget.identifier,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.lightGreen[900],
                  ),
                  textAlign: TextAlign.center, // Center text
                ),
              ),
              SizedBox(height: 30),
              _buildProfileInfo('Customer ID', widget.identifier),
              _buildProfileInfo(
                'Loyalty Points',
                _loyaltyPoints.isNotEmpty ? _loyaltyPoints : '0',
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => _logoutCustomer(context),
                icon: Icon(Icons.logout),
                label: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: _isDarkMode ? Colors.black : Colors.white, // Set background color based on mode
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Help',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _isDarkMode ? Colors.white : Colors.black, // Change selected item color
        unselectedItemColor: _isDarkMode ? Colors.white70 : Colors.black, // Unselected item color for dark mode
        backgroundColor: _isDarkMode ? Colors.black : Colors.green[100], // Custom color for the navigation bar
        onTap: _onItemTapped,
        // Highlight with animation when pressed
        selectedFontSize: 14,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container( // Box for profile info
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
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
            Text(
              value,
              style: TextStyle(
                fontSize: 16.0,
                color: _isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logoutCustomer(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/loginselection');
  }
}
