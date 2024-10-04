import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:image_picker/image_picker.dart';

class FoodMakerSignUpPage extends StatefulWidget {
  @override
  _FoodMakerSignUpPageState createState() => _FoodMakerSignUpPageState();
}

class _FoodMakerSignUpPageState extends State<FoodMakerSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  XFile? _profileImage;
  XFile? _certificationImage;

  Future<void> _registerFoodMaker() async {
    final url = 'http://192.168.1.26:8000/api/register-foodmaker';

    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add form data (ensure all fields are correctly mapped)
    request.fields['full_name'] = _formData['full_name'];
    request.fields['business_name'] = _formData['business_name'] ?? '';
    request.fields['email'] = _formData['email'];
    request.fields['phone'] = _formData['phone'];
    request.fields['password'] = _formData['password'];
    request.fields['address'] = _formData['address'];
    request.fields['bio'] = _formData['bio'];
    request.fields['cuisine_specialties'] = json.encode(_formData['cuisine_specialties'] ?? []);
    request.fields['delivery_options'] = _formData['delivery_options'] == true ? 'Delivery' : 'Takeaway';

    if (_profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_picture', _profileImage!.path));
    }
    if (_certificationImage != null) {
      request.files.add(await http.MultipartFile.fromPath('certification', _certificationImage!.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );
    } else {
      // Read response body for error message
      final responseBody = await response.stream.bytesToString();
      print('Response Body: $responseBody');
      final responseHeaders = response.headers; // Inspect headers for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${response.statusCode} - $responseBody')),
      );

      // Debugging output
      print('Response Headers: $responseHeaders');
    }
  }

  Future<void> _pickImage(bool isProfile) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (isProfile) {
        _profileImage = pickedFile;
      } else {
        _certificationImage = pickedFile;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCAF1BC), // Light green background
      appBar: AppBar(
        title: Text(
          'Food Maker Sign Up',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20), // Top spacing
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.lightGreen[900]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightGreen[900]!),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  _formData['full_name'] = value;
                  return null;
                },
              ),
              SizedBox(height: 16), // Spacing between fields
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Business Name (Optional)',
                  labelStyle: TextStyle(color: Colors.lightGreen[900]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightGreen[900]!),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (value) {
                  _formData['business_name'] = value;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: Colors.lightGreen[900]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightGreen[900]!),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  _formData['email'] = value;
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.lightGreen[900]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightGreen[900]!),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  _formData['phone'] = value;
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.lightGreen[900]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightGreen[900]!),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  _formData['password'] = value;
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.lightGreen[900]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightGreen[900]!),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _formData['password']) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Location/Address',
                  labelStyle: TextStyle(color: Colors.lightGreen[900]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightGreen[900]!),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  _formData['address'] = value;
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _pickImage(true), // Pick profile image
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen[900], // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Upload Profile Picture/Logo',
                  style: TextStyle(color: Colors.white), // White text
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Food Maker Bio',
                  labelStyle: TextStyle(color: Colors.lightGreen[900]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightGreen[900]!),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a brief bio';
                  }
                  _formData['bio'] = value;
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<bool>(
                decoration: InputDecoration(
                  labelText: 'Delivery Options',
                  labelStyle: TextStyle(color: Colors.lightGreen[900]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightGreen[900]!),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                value: _formData['delivery_options'] ?? true,
                onChanged: (bool? newValue) {
                  setState(() {
                    _formData['delivery_options'] = newValue!;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: true,
                    child: Text('Delivery'),
                  ),
                  DropdownMenuItem(
                    value: false,
                    child: Text('Takeaway'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _pickImage(false), // Pick certification image
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Upload Certification',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _registerFoodMaker();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Register',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
