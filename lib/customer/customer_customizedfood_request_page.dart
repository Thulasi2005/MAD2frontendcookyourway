import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode

class CustomizeFoodPage extends StatefulWidget {
  @override
  _CustomizeFoodPageState createState() => _CustomizeFoodPageState();
}

class _CustomizeFoodPageState extends State<CustomizeFoodPage> {
  final _formKey = GlobalKey<FormState>();
  String foodName = '';
  int quantity = 1;
  String portionSize = 'Small';
  String foodDescription = '';
  String priceRange = '';
  String address = '';
  String deliveryMethod = 'Pickup';
  bool isDarkMode = false; // Track dark mode status

  List<String> portionSizes = ['Small', 'Medium', 'Large'];
  List<String> deliveryMethods = ['Pickup', 'Delivery'];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Get identifier from route arguments
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>? ?? {};
      String identifier = args['identifier'] ?? 'User';

      // Create a Map of the form data
      Map<String, dynamic> data = {
        'food_name': foodName,
        'quantity': quantity,
        'portion_size': portionSize,
        'food_description': foodDescription,
        'price_range': priceRange,
        'address': address,
        'delivery_method': deliveryMethod,
        'identifier': identifier, // Send the identifier
      };

      // Make a POST request to the backend
      final response = await http.post(
        Uri.parse('http://192.168.1.26:8000/api/food-customizations'), // Update this with your API URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        // Successfully customized food
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Food customized successfully!')),
        );
        // Optionally navigate to another page or reset the form
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to customize food: ${response.body}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>? ?? {};
    String identifier = args['identifier'] ?? 'User';

    // Determine theme colors
    Color backgroundColor = isDarkMode ? Color(0xFF1C1C1C) : Color(0xFFCAF1BC); // Greyish black for dark mode
    Color textColor = isDarkMode ? Color(0xFF4CAF50) : Colors.black; // Greenish shade for text in dark mode
    Color labelColor = isDarkMode ? Color(0xFF4CAF50) : Color(0xFF4CAF50); // Greenish shade for labels
    Color borderColor = isDarkMode ? Colors.white : Colors.grey; // Border color for dark mode
    Color buttonColor = isDarkMode ? Color(0xFF4CAF50) : Color(0xFF4CAF50); // Greenish shade for buttons
    Color cardColor = isDarkMode ? Color(0xFF424242) : Colors.white; // Card color

    return Scaffold(
      appBar: AppBar(
        title: Text('Customize Food'),
        backgroundColor: isDarkMode ? Color(0xFF4CAF50) : buttonColor, // Light shade for dark mode
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode; // Toggle dark mode
              });
            },
          ),
        ],
      ),
      body: Container(
        color: backgroundColor, // Background color
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Card(
              color: cardColor, // Card color
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $identifier!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    SizedBox(height: 20),

                    // Food Name Input
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Food Name',
                        labelStyle: TextStyle(color: labelColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: labelColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a food name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        foodName = value!;
                      },
                    ),
                    SizedBox(height: 10),

                    // Quantity Input
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Quantity (in persons)',
                        labelStyle: TextStyle(color: labelColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: labelColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Please enter a valid quantity';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        quantity = int.parse(value!);
                      },
                    ),
                    SizedBox(height: 10),

                    // Portion Size Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Portion Size',
                        labelStyle: TextStyle(color: labelColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: labelColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      value: portionSize,
                      items: portionSizes.map((String size) {
                        return DropdownMenuItem<String>(
                          value: size,
                          child: Text(size, style: TextStyle(color: textColor)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          portionSize = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    // Food Description Input
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Food Description',
                        labelStyle: TextStyle(color: labelColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: labelColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        foodDescription = value!;
                      },
                    ),
                    SizedBox(height: 10),

                    // Price Range Input
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Price Range',
                        labelStyle: TextStyle(color: labelColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: labelColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a price range';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        priceRange = value!;
                      },
                    ),
                    SizedBox(height: 10),

                    // Address Input
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Address',
                        labelStyle: TextStyle(color: labelColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: labelColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        address = value!;
                      },
                    ),
                    SizedBox(height: 10),

                    // Delivery Method Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Delivery Method',
                        labelStyle: TextStyle(color: labelColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: labelColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      value: deliveryMethod,
                      items: deliveryMethods.map((String method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method, style: TextStyle(color: textColor)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          deliveryMethod = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 20),

                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor, // Button color
                        ),
                        child: Text(
                          'Submit Customization',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
