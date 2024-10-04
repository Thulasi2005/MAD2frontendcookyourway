import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomizedRequestsPage extends StatefulWidget {
  @override
  _CustomizedRequestsPageState createState() => _CustomizedRequestsPageState();
}

class _CustomizedRequestsPageState extends State<CustomizedRequestsPage> {
  late String identifier;
  late String token;
  List<FoodCustomization> requests = [];
  bool isLoading = true;

  // Initially set to light mode
  bool isDarkMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    identifier = args['identifier'];
    token = args['token'];

    // Fetch customized requests from the API
    fetchCustomizedRequests();
  }

  // Function to toggle between light and dark modes
  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  Future<void> fetchCustomizedRequests() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.26:8000/api/response/food_customizations'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        requests = data.map((json) => FoodCustomization.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load requests')),
      );
    }
  }

  Future<void> acceptRequest(int requestId) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.26:8000/api/food_customizations/$requestId/accept'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'chef_identifier': identifier}),
    );

    if (response.statusCode == 200) {
      setState(() {
        requests.removeWhere((request) => request.id == requestId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request accepted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept request: ${response.statusCode} - ${response.body}')),
      );
    }
  }

  Future<void> declineRequest(int requestId) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.26:8000/api/food_customizations/$requestId/decline'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'chef_identifier': identifier}),
    );

    if (response.statusCode == 200) {
      setState(() {
        requests.removeWhere((request) => request.id == requestId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request declined successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decline request: ${response.statusCode} - ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: isDarkMode ? Colors.black : Colors.white,
        cardColor: isDarkMode ? Colors.grey[800] : Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Customized Requests'),
          backgroundColor: isDarkMode ? Colors.black : Colors.green[700],
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 4,
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: toggleTheme, // Toggle the theme mode
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Text(
                'Customized Requests for Chef $identifier',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.green[900],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    return _buildRequestCard(requests[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(FoodCustomization request) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request #${request.id}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text('Food Name: ${request.foodName}', style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black)),
            SizedBox(height: 8),
            Text('Quantity: ${request.quantity}', style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black)),
            SizedBox(height: 8),
            Text('Portion Size: ${request.portionSize}', style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black)),
            SizedBox(height: 8),
            Text('Description: ${request.foodDescription}', style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black)),
            SizedBox(height: 8),
            Text('Price Range: ${request.priceRange}', style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black)),
            SizedBox(height: 8),
            Text('Address: ${request.address}', style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black)),
            SizedBox(height: 8),
            Text('Delivery Method: ${request.deliveryMethod}', style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black)),
            SizedBox(height: 8),
            Text('Identifier: ${request.identifier}', style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.black)),
            SizedBox(height: 8),
            Text(
              'Status: ${request.status}',
              style: TextStyle(
                fontSize: 16,
                color: request.status == 'Pending' ? (isDarkMode ? Colors.orange[300] : Colors.orange) : (isDarkMode ? Colors.green[300] : Colors.green),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    acceptRequest(request.id);
                  },
                  child: Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    declineRequest(request.id);
                  },
                  child: Text('Decline'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// FoodCustomization model
class FoodCustomization {
  final int id;
  final String foodName;
  final int quantity;
  final String portionSize;
  final String foodDescription;
  final String priceRange;
  final String address;
  final String deliveryMethod;
  final String identifier;
  final String status;

  FoodCustomization({
    required this.id,
    required this.foodName,
    required this.quantity,
    required this.portionSize,
    required this.foodDescription,
    required this.priceRange,
    required this.address,
    required this.deliveryMethod,
    required this.identifier,
    required this.status,
  });

  factory FoodCustomization.fromJson(Map<String, dynamic> json) {
    return FoodCustomization(
      id: json['id'],
      foodName: json['food_name'],
      quantity: json['quantity'],
      portionSize: json['portion_size'],
      foodDescription: json['food_description'],
      priceRange: json['price_range'],
      address: json['address'],
      deliveryMethod: json['delivery_method'],
      identifier: json['identifier'],
      status: json['status'],
    );
  }
}
