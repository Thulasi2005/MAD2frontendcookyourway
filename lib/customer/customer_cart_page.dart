import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'customer_checkout_page.dart'; // Import the CheckoutPage

class CartPage extends StatefulWidget {
  final String token;

  CartPage({required this.token});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  bool hasError = false;
  bool isDarkMode = false; // State to track dark mode

  @override
  void initState() {
    super.initState();
    print("Token received: ${widget.token}"); // Print the token to verify
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.26:8000/api/cart?token=${widget.token}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        setState(() {
          cartItems = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (error) {
      print('Error fetching cart items: $error');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // Update item quantity
  Future<void> updateQuantity(int itemId, int newQuantity) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.26:8000/api/cart/update'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': widget.token,
          'item_id': itemId,
          'quantity': newQuantity,
        }),
      );

      if (response.statusCode == 200) {
        fetchCartItems();
      } else {
        throw Exception('Failed to update quantity');
      }
    } catch (error) {
      print('Error updating quantity: $error');
    }
  }

  // Remove item from cart
  Future<void> removeItem(int itemId) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.26:8000/api/cart/remove'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': widget.token,
          'item_id': itemId,
        }),
      );

      if (response.statusCode == 200) {
        fetchCartItems();
      } else {
        throw Exception('Failed to remove item');
      }
    } catch (error) {
      print('Error removing item: $error');
    }
  }

  // Toggle dark mode
  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  // Navigate to CheckoutPage
  void navigateToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          cartItems: cartItems,
          token: widget.token,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.green,
        actions: [
          Switch(
            value: isDarkMode,
            onChanged: toggleTheme,
            activeColor: Colors.white,
          ),
        ],
      ),
      body: Container(
        color: isDarkMode ? Colors.black : Color(0xFFCAF1BC),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : hasError
            ? Center(child: Text('Failed to load cart items.', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)))
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    elevation: 5,
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            item['description'],
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${item['price']}',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, color: isDarkMode ? Colors.white : Colors.black),
                                    onPressed: () {
                                      if (item['quantity'] > 1) {
                                        updateQuantity(item['item_id'], item['quantity'] - 1);
                                      }
                                    },
                                  ),
                                  Text(
                                    item['quantity'].toString(),
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add, color: isDarkMode ? Colors.white : Colors.black),
                                    onPressed: () {
                                      updateQuantity(item['item_id'], item['quantity'] + 1);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: navigateToCheckout, // Navigate to Checkout
              child: Text('Checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                padding: EdgeInsets.all(16.0), // Button padding
              ),
            ),
          ],
        ),
      ),
    );
  }
}
