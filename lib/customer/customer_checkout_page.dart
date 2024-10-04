import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String token;

  CheckoutPage({required this.cartItems, required this.token});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _deliveryOption = 'Delivery'; // Default option
  String _totalAmount = ''; // Total amount variable
  String? _selectedPaymentMethod; // Variable to store selected payment method
  String? _cardHolderName; // Cardholder Name
  String? _cardNumber; // Card Number
  String? _expiryDate; // Expiry Date
  String? _cvc; // CVC
  bool _isDarkMode = false; // Variable for theme mode

  @override
  void initState() {
    super.initState();
    _calculateTotalAmount(); // Calculate total amount when the page is initialized
  }

  void _calculateTotalAmount() {
    double total = widget.cartItems.fold(0.0, (sum, item) {
      double price = double.tryParse(item['price'].toString()) ?? 0.0;
      return sum + (price * item['quantity']);
    });
    setState(() {
      _totalAmount = total.toStringAsFixed(2); // Format to 2 decimal places
    });
  }

  Future<void> _submitCheckout() async {
    final String address = _addressController.text;
    final String description = _descriptionController.text;

    // Validate necessary fields
    if (address.isEmpty ||
        _selectedPaymentMethod == null ||
        (_selectedPaymentMethod == 'Credit Card' &&
            (_cardHolderName == null || _cardNumber == null || _expiryDate == null || _cvc == null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    final url = 'http://192.168.1.26:8000/api/orders'; // Replace with your actual API URL
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'address': address,
      'description': description,
      'delivery_option': _deliveryOption,
      'total_amount': _totalAmount,
      'cart_items': widget.cartItems,
      'token': widget.token,
      'payment_method': _selectedPaymentMethod,
      'card_details': _selectedPaymentMethod == 'Credit Card'
          ? {
        'card_holder_name': _cardHolderName,
        'card_number': _cardNumber,
        'expiry_date': _expiryDate,
        'cvc': _cvc,
      }
          : null,
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Checkout successful: ${response.body}');
        // Navigate to success page or show success message
      } else {
        print('Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print("Error during checkout: $e");
    }
  }

  // Function to show a dialog for selecting payment method
  void _selectPaymentMethod() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('Credit Card'),
                value: 'Credit Card',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  _showCardDetailsForm(); // Show card details form
                },
              ),
              RadioListTile<String>(
                title: Text('Cash on Delivery'),
                value: 'Cash on Delivery',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show a form for entering card details
  void _showCardDetailsForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _cardHolderNameController = TextEditingController();
        final _cardNumberController = TextEditingController();
        final _expiryDateController = TextEditingController();
        final _cvcController = TextEditingController();

        return AlertDialog(
          title: Text('Enter Card Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _cardHolderNameController,
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _expiryDateController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date (MM/YY)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _cvcController,
                decoration: InputDecoration(
                  labelText: 'CVC',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _cardHolderName = _cardHolderNameController.text;
                  _cardNumber = _cardNumberController.text;
                  _expiryDate = _expiryDateController.text;
                  _cvc = _cvcController.text;
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // Function to toggle dark mode
  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode; // Toggle the dark mode value
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: _isDarkMode ? Colors.grey[850] : Colors.green,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: _toggleDarkMode, // Toggle dark mode on button press
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isPortrait
            ? _buildPortraitLayout()
            : _buildLandscapeLayout(screenWidth, screenHeight),
      ),
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
    );
  }

  // Portrait layout with single-column design
  Widget _buildPortraitLayout() {
    return ListView(
      children: [
        Text('Items in your cart:', style: TextStyle(fontSize: 20, color: _isDarkMode ? Colors.white : Colors.black)),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.cartItems.length,
          itemBuilder: (context, index) {
            final item = widget.cartItems[index];
            return ListTile(
              title: Text(item['name'], style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
              subtitle: Text('Quantity: ${item['quantity']} - Price: \$${item['price']}', style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black87)),
            );
          },
        ),
        SizedBox(height: 20),
        Text('Total: \$$_totalAmount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black)),
        SizedBox(height: 20),
        TextField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Delivery Address',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: _isDarkMode ? Colors.white : Colors.black)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
          ),
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Additional Description (optional)',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: _isDarkMode ? Colors.white : Colors.black)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
          ),
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
        ),
        SizedBox(height: 20),
        Text('Delivery Option:', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
        DropdownButton<String>(
          value: _deliveryOption,
          items: <String>['Delivery', 'Pickup'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _deliveryOption = newValue!;
            });
          },
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _selectPaymentMethod,
          child: Text('Select Payment Method'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submitCheckout,
          child: Text('Checkout'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }

  // Landscape layout with two-column design
  Widget _buildLandscapeLayout(double screenWidth, double screenHeight) {
    return Row(
      children: [
        Container(
          width: screenWidth * 0.5,
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text('Items in your cart:', style: TextStyle(fontSize: 20, color: _isDarkMode ? Colors.white : Colors.black)),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return ListTile(
                    title: Text(item['name'], style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                    subtitle: Text('Quantity: ${item['quantity']} - Price: \$${item['price']}', style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black87)),
                  );
                },
              ),
            ],
          ),
        ),
        VerticalDivider(width: 1, color: _isDarkMode ? Colors.white : Colors.black),
        Container(
          width: screenWidth * 0.5,
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text('Total: \$$_totalAmount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black)),
              SizedBox(height: 20),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: _isDarkMode ? Colors.white : Colors.black)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                ),
                style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Additional Description (optional)',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: _isDarkMode ? Colors.white : Colors.black)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                ),
                style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
              ),
              SizedBox(height: 20),
              Text('Delivery Option:', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
              DropdownButton<String>(
                value: _deliveryOption,
                items: <String>['Delivery', 'Pickup'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _deliveryOption = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _selectPaymentMethod,
                child: Text('Select Payment Method'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitCheckout,
                child: Text('Checkout'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
