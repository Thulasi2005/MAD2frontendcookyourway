import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'customer_payment_page.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> _customizations = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? token;
  String identifier = 'User';
  bool _isDarkMode = false;
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    if (args != null) {
      token = args['token'];
      identifier = args['identifier'] ?? 'User';
      _fetchCustomizations();
    }
  }

  Future<void> _fetchCustomizations() async {
    if (token != null) {
      final response = await http.get(
        Uri.parse('http://192.168.1.26:8000/api/response/food_customizations'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _customizations = data;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        print('Failed to load customizations: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isDarkMode
                ? [Colors.black, Colors.grey[900]!]
                : [Color(0xFFCAF1BC), Color(0xFFE8F5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isDarkMode ? Colors.white : Colors.green,
                  ),
                ),
              )
                  : _hasError
                  ? Center(
                child: Text(
                  'Failed to load orders. Please try again later.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.red : Colors.black,
                    fontSize: 16,
                  ),
                ),
              )
                  : _buildOrderList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(100.0),
      child: Container(
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.grey[900] : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: AppBar(
          title: Text(
            'Your Orders',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Color(0xFF388E3C),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 100,
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                color: _isDarkMode ? Colors.yellow : Colors.grey[800],
              ),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $identifier!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Color(0xFF3E2723),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Here are your current food customizations:',
            style: TextStyle(
              fontSize: 16,
              color: _isDarkMode ? Colors.white70 : Color(0xFF5D4037),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _customizations.length,
              itemBuilder: (context, index) {
                final customization = _customizations[index];
                final isAccepted = customization['status'] == 'Accepted';
                return _buildOrderCard(customization, isAccepted);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic customization, bool isAccepted) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: _isDarkMode ? Colors.green : Color(0xFF66BB6A),
          width: 2,
        ),
      ),
      color: _isDarkMode ? Colors.grey[850] : Color(0xFFDCEDC8),  // Lighter green for light mode, grey for dark
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${customization['id']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 10),
            _buildCustomizationDetail('Food', customization['food_name']),
            _buildCustomizationDetail('Quantity', customization['quantity']),
            _buildCustomizationDetail('Portion Size', customization['portion_size']),
            _buildCustomizationDetail('Price Range', customization['price_range']),
            _buildCustomizationDetail('Delivery Method', customization['delivery_method']),
            _buildCustomizationDetail('Address', customization['address']),
            _buildCustomizationDetail('Description', customization['food_description']),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: isAccepted ? () => _handlePayment(customization['id'].toString()) : null,
                child: Text('Pay Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDarkMode ? Colors.black : Color(0xFF388E3C),
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationDetail(String label, dynamic value) {
    return Text(
      '$label: $value',
      style: TextStyle(
        color: _isDarkMode ? Colors.white70 : Colors.black87,
      ),
    );
  }

  void _handlePayment(String orderId) {
    final customization = _customizations.firstWhere(
          (c) => c['id'].toString() == orderId,
      orElse: () => null,
    );

    if (customization != null) {
      double amount = double.tryParse(customization['price_range']?.toString() ?? '0.0') ?? 0.0;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            orderId: orderId,
            amount: amount,
          ),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Help'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: _isDarkMode ? Colors.white : Color(0xFF004D40),
      unselectedItemColor: _isDarkMode ? Colors.grey : Color(0xFF80CBC4),
      backgroundColor: _isDarkMode ? Colors.black : Color(0xFFE0F2F1),
      onTap: _onItemTapped,
    );
  }
}
