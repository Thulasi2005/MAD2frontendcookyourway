import 'package:flutter/material.dart';

class CustomerHomePage extends StatefulWidget {
  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // Tracks the selected index for bottom navigation
  String identifier = 'User'; // Move identifier and token to class-level
  String token = '';
  bool _isDarkMode = false; // Track dark mode state

  // Animation Controller for button press animations
  late AnimationController _controller;
  late Animation<double> _animation;

  // Method to handle navigation when a bottom nav item is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation logic based on selected index
    switch (index) {
      case 0: // Home
        Navigator.pushNamed(context, '/customerhomepage', arguments: {'identifier': identifier, 'token': token});
        break;
      case 1: // Orders
        Navigator.pushNamed(context, '/customercustomizedresponse', arguments: {'identifier': identifier, 'token': token});
        break;
      case 2: // Profile
        Navigator.pushNamed(context, '/customerprofile', arguments: {
          'identifier': identifier,
          'token': token,
        });
        break;
      case 3: // Help
        Navigator.pushNamed(context, '/helppage', arguments: {'identifier': identifier, 'token': token});
        break;
    }
  }

  // Toggle between dark and light mode
  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extracting arguments passed from the LoginPage
    final args = ModalRoute.of(context)?.settings.arguments;

    // Safely casting arguments
    if (args is Map<String, String>) {
      identifier = args['identifier'] ?? 'User'; // Assign value to class-level variable
      token = args['token'] ?? '';

      return MaterialApp(
        theme: _isDarkMode ? _darkTheme() : _lightTheme(), // Set theme based on dark mode state
        home: Scaffold(
          backgroundColor: _isDarkMode ? Color(0xFF212121) : Color(0xFFCAF1BC), // Set background color
          appBar: AppBar(
            title: Text('Customer Home'),
            backgroundColor: _isDarkMode ? Color(0xFF424242) : Color(0xFFCAF1BC),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: _toggleDarkMode,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Welcome Message
                  Text(
                    'Welcome back, $identifier!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _isDarkMode ? Colors.white : Colors.brown[800], // Dark mode text color
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Feeling hungry? Let’s meet your cravings!',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isDarkMode ? Colors.white70 : Colors.brown[600], // Dark mode subtext color
                    ),
                  ),
                  SizedBox(height: 20),
                  // Explore Message in the middle and bold
                  Center(
                    child: Text(
                      'Explore the best dishes around you!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.green[800], // Dark mode content color
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Options for the Home Page in vertical order
                  Column(
                    children: [
                      _buildOptionCard(
                        title: 'Browse Menu',
                        icon: Icons.menu_book,
                        onTap: () {
                          Navigator.pushNamed(context, '/customerbrowsemenu', arguments: {'identifier': identifier, 'token': token});
                        },
                      ),
                      SizedBox(height: 20), // Spacing between cards
                      _buildOptionCard(
                        title: 'Create Customized Food',
                        icon: Icons.create,
                        onTap: () {
                          Navigator.pushNamed(context, '/customercustomizedrequests', arguments: {'identifier': identifier, 'token': token});
                        },
                      ),
                      SizedBox(height: 20), // Spacing between cards
                      _buildOptionCard(
                        title: 'Ratings & Reviews',
                        icon: Icons.rate_review,
                        onTap: () {
                          Navigator.pushNamed(context, '/ratingsReviews');
                        },
                      ),
                      SizedBox(height: 20), // Spacing between cards
                      _buildOptionCard(
                        title: 'More Options',
                        icon: Icons.more_horiz,
                        onTap: () {
                          // Handle more options
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bottom Navigation Bar with custom color
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
            backgroundColor: _isDarkMode ? Colors.black : Colors.green[100], // Custom color for the navigation barn bar
            onTap: _onItemTapped,
            // Highlight with animation when pressed
            selectedFontSize: 14,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      );
    } else {
      // Handle the case where args is not a valid Map
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('Invalid arguments passed to Customer Home Page.'),
        ),
      );
    }
  }

  // Define light theme
  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFFCAF1BC),
      ),
    );
  }

  // Define dark theme
  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF424242),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _controller.forward().then((_) {
          _controller.reverse();
        });
        onTap();
      },
      child: ScaleTransition(
        scale: _animation,
        child: Card(
          color: _isDarkMode ? Colors.grey[800] : Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.green[800]!, width: 2), // Border for the card
          ),
          child: Container(
            width: 200, // Set width for uniformity
            height: 150, // Set height for uniformity
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.green[800], // Dark green color for icons
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.brown[800], // Dark mode text color
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
