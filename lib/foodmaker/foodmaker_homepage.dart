import 'package:flutter/material.dart';

class FoodMakerHomePage extends StatefulWidget {
  final String identifier;
  final String token;

  const FoodMakerHomePage({Key? key, required this.identifier, required this.token}) : super(key: key);

  @override
  _FoodMakerHomePageState createState() => _FoodMakerHomePageState();
}

class _FoodMakerHomePageState extends State<FoodMakerHomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.forward().then((value) {
      _controller.reverse();
    });

    // Navigate to the corresponding page
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/foodmakerhomepage'); // Home page
        break;
      case 1:
        Navigator.pushNamed(context, '/foodmakerprofile', arguments: {
          'identifier': widget.identifier,
          'token': widget.token,
        }); // Profile page
        break;
      case 2:
        Navigator.pushNamed(context, '/foodmakerpaymentreceival', arguments: {
          'identifier': widget.identifier,
          'token': widget.token,
        }); // Payment Receival page
        break;
      case 3:
        Navigator.pushNamed(context, '/tracking'); // Tracking page
        break;
      default:
        break;
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : const Color(0xFFCAF1BC),
      appBar: AppBar(
        title: const Text('Food Maker Home'),
        backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome message
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Welcome back, Chef ${widget.identifier}!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.green[900],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ready to Cook?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: _isDarkMode ? Colors.grey[300] : Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Option buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOptionButton(
                    icon: Icons.menu,
                    label: 'Menu',
                    onTap: () => Navigator.pushNamed(context, '/foodmakermenu', arguments: {
                      'identifier': widget.identifier,
                      'token': widget.token,
                    }),
                  ),
                  const SizedBox(height: 20),
                  _buildOptionButton(
                    icon: Icons.star,
                    label: 'Customized Requests',
                    onTap: () => Navigator.pushNamed(context, '/foodmakerresponsetocustomized', arguments: {
                      'identifier': widget.identifier,
                      'token': widget.token,
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _isDarkMode ? Colors.grey[850] : Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Tracking',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _isDarkMode ? Colors.green : Colors.green[700],
        unselectedItemColor: _isDarkMode ? Colors.grey : Colors.grey[800],
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Helper method to build option buttons
  Widget _buildOptionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.grey[800] : Colors.green[800],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: _isDarkMode ? Colors.white70 : Colors.green[600]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
