import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ItemDetailsPage extends StatefulWidget {
  final int itemId;
  final String token;
  final String identifier;

  ItemDetailsPage({
    required this.itemId,
    required this.token,
    required this.identifier,
  });

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  Map<String, dynamic>? itemDetails;
  int quantity = 1;
  bool isDarkMode = false; // State for dark mode

  @override
  void initState() {
    super.initState();
    fetchItemDetails();
  }

  Future<void> fetchItemDetails() async {
    try {
      print('Fetching item details...');
      final response = await http.get(
        Uri.parse('http://192.168.1.26:8000/api/menu/item/${widget.itemId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          itemDetails = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load item details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching item details: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load item details: $error'),
      ));
    }
  }

  Future<void> addToCart() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.26:8000/api/cart/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'item_id': widget.itemId,
          'quantity': quantity,
          'name': itemDetails!['name'],
          'description': itemDetails!['description'],
          'price': itemDetails!['price'],
          'token': widget.token,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Item added to cart!'),
        ));
      } else {
        throw Exception('Failed to add item to cart: ${response.body}');
      }
    } catch (error) {
      print('Error adding to cart: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add item to cart: $error'),
      ));
    }
  }

  void toggleTheme(bool? value) {
    setState(() {
      isDarkMode = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Item Details'),
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.green[100], // AppBar color for dark mode
          actions: [
            Switch(
              value: isDarkMode,
              onChanged: toggleTheme,
              activeColor: Colors.white,
            ),
          ],
        ),
        body: itemDetails == null
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF424242) : Color(0xFFCAF1BC), // Background color for the box
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemDetails!['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    itemDetails!['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '\$${itemDetails!['price']}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.green[300] : Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Quantity:',
                        style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      SizedBox(width: 10),
                      DropdownButton<int>(
                        value: quantity,
                        onChanged: (value) {
                          setState(() {
                            quantity = value!;
                          });
                        },
                        items: List.generate(10, (index) => index + 1)
                            .map<DropdownMenuItem<int>>(
                              (int value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          ),
                        )
                            .toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: addToCart,
                    child: Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.green[600] : Colors.green[600], // Button color for dark mode
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
