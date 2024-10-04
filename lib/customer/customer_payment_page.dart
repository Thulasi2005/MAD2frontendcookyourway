import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPage extends StatefulWidget {
  final String orderId; // Order ID to track payment
  final double amount;

  PaymentPage({required this.amount, required this.orderId});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isCashPayment = false;
  bool _isDarkMode = false; // Track the theme state
  final _cardHolderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvcController = TextEditingController();

  Future<void> _submitPayment() async {
    String paymentMethod = _isCashPayment ? "Cash" : "Card";

    // Collect payment details
    String cardHolderName = _cardHolderNameController.text;
    String cardNumber = _cardNumberController.text;
    String cardExpiry = _cardExpiryController.text;
    String cardCvc = _cardCvcController.text;

    // Create the payload
    Map<String, dynamic> payload = {
      'order_id': widget.orderId,
      'amount': widget.amount,
      'payment_method': paymentMethod,
      'card_holder_name': cardHolderName,
      'card_number': cardNumber,
      'expiry_date': cardExpiry,
      'cvc': cardCvc,
    };

    try {
      // Send payment details to the Laravel backend
      final response = await http.post(
        Uri.parse('http://192.168.1.26:8000/api/payments'), // Change this URL to your Laravel endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        // Payment successful
        _showSuccessDialog(paymentMethod, cardHolderName, cardNumber, cardExpiry, cardCvc);
      } else {
        // Handle errors
        _showErrorDialog('Payment failed. Please try again.');
      }
    } catch (e) {
      // Handle network errors
      _showErrorDialog('An error occurred: $e');
    }
  }

  void _showSuccessDialog(String paymentMethod, String cardHolderName, String cardNumber, String cardExpiry, String cardCvc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Payment Successful!'),
          content: Text('Payment method: $paymentMethod\n'
              'Order ID: ${widget.orderId}\n'
              'Amount: \$${widget.amount}\n'
              'Cardholder Name: $cardHolderName\n'
              'Card Number: $cardNumber\n'
              'Expiry: $cardExpiry\n'
              'CVC: $cardCvc'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on theme
    Color backgroundColor = _isDarkMode ? Colors.grey[850]! : Color(0xFFCAF1BC);
    Color appBarColor = _isDarkMode ? Colors.grey[800]! : Colors.teal;
    Color orderColor = _isDarkMode ? Colors.grey[700]! : Colors.greenAccent;
    Color textColor = _isDarkMode ? Colors.white : Colors.black;
    Color textFieldColor = _isDarkMode ? Colors.grey[800]! : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: appBarColor,
        actions: [
          // Toggle button for dark/light mode
          IconButton(
            icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode; // Toggle the theme
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        padding: EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Adjust layout based on orientation
            if (constraints.maxWidth > constraints.maxHeight) {
              // Landscape orientation
              return Row(
                children: [
                  Expanded(
                    child: _buildPaymentForm(textColor, textFieldColor),
                  ),
                ],
              );
            } else {
              // Portrait orientation
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentForm(textColor, textFieldColor),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPaymentForm(Color textColor, Color textFieldColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total: \$${widget.amount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Radio(
              value: true,
              groupValue: _isCashPayment,
              onChanged: (value) {
                setState(() {
                  _isCashPayment = true;
                });
              },
              activeColor: Colors.teal,
            ),
            Text('Cash', style: TextStyle(color: textColor)),
            Radio(
              value: false,
              groupValue: _isCashPayment,
              onChanged: (value) {
                setState(() {
                  _isCashPayment = false;
                });
              },
              activeColor: Colors.teal,
            ),
            Text('Card', style: TextStyle(color: textColor)),
          ],
        ),
        if (!_isCashPayment) ...[
          TextField(
            controller: _cardHolderNameController,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: textFieldColor,
              labelStyle: TextStyle(color: textColor),
            ),
            style: TextStyle(color: textColor),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Card Number',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: textFieldColor,
              labelStyle: TextStyle(color: textColor),
            ),
            keyboardType: TextInputType.number,
            style: TextStyle(color: textColor),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _cardExpiryController,
            decoration: InputDecoration(
              labelText: 'Expiry Date (MM/YY)',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: textFieldColor,
              labelStyle: TextStyle(color: textColor),
            ),
            keyboardType: TextInputType.datetime,
            style: TextStyle(color: textColor),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _cardCvcController,
            decoration: InputDecoration(
              labelText: 'CVC',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: textFieldColor,
              labelStyle: TextStyle(color: textColor),
            ),
            keyboardType: TextInputType.number,
            style: TextStyle(color: textColor),
          ),
        ],
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: _submitPayment,
            child: Text('Submit Payment'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              textStyle: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
