import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class CustomerSignUpPage extends StatefulWidget {
  @override
  _CustomerSignUpPageState createState() => _CustomerSignUpPageState();
}

class _CustomerSignUpPageState extends State<CustomerSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  XFile? _profileImage;
  List<String> selectedAllergies = [];

  final List<String> allergiesOptions = [
    "Peanuts",
    "Tree Nuts",
    "Milk",
    "Eggs",
    "Fish",
    "Shellfish",
    "Soy",
    "Wheat",
    "Other",
  ];

  Future<void> _registerCustomer() async {
    final url = 'http://192.168.1.26:8000/api/register-customer';

    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add form data
    request.fields['full_name'] = _formData['full_name'];
    request.fields['email'] = _formData['email'];
    request.fields['phone'] = _formData['phone'];
    request.fields['password'] = _formData['password'];
    request.fields['password_confirmation'] = _formData['password_confirmation'];
    request.fields['address'] = _formData['address'];
    request.fields['cuisine'] = _formData['cuisine'] ?? '';

    // Add allergies as individual fields
    for (var allergy in selectedAllergies) {
      request.fields['allergies[]'] = allergy; // Append each allergy separately
    }

    if (_profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_picture', _profileImage!.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );
    } else {
      final responseBody = await response.stream.bytesToString();
      print('Response Body: $responseBody');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${response.statusCode} - $responseBody')),
      );
    }
  }


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _profileImage = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCAF1BC),
      appBar: AppBar(
        title: Text('Customer Sign Up', style: TextStyle(color: Colors.black)),
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
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Full Name', labelStyle: TextStyle(color: Colors.lightGreen[900])),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  _formData['full_name'] = value;
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email Address', labelStyle: TextStyle(color: Colors.lightGreen[900])),
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
                decoration: InputDecoration(labelText: 'Phone Number', labelStyle: TextStyle(color: Colors.lightGreen[900])),
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
                decoration: InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: Colors.lightGreen[900])),
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
                decoration: InputDecoration(labelText: 'Confirm Password', labelStyle: TextStyle(color: Colors.lightGreen[900])),
                obscureText: true,
                validator: (value) {
                  if (value != _formData['password']) {
                    return 'Passwords do not match';
                  }
                  _formData['password_confirmation'] = value; // Store confirmation password
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location/Address', labelStyle: TextStyle(color: Colors.lightGreen[900])),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  _formData['address'] = value;
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Cuisine', labelStyle: TextStyle(color: Colors.lightGreen[900])),
                items: <String>['Italian', 'Indian', 'Chinese', 'American', 'Other']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _formData['cuisine'] = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a cuisine' : null,
              ),
              SizedBox(height: 16),
              Text("Select Allergies:", style: TextStyle(color: Colors.lightGreen[900])),
              ...allergiesOptions.map((allergy) {
                return CheckboxListTile(
                  title: Text(allergy),
                  value: selectedAllergies.contains(allergy),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedAllergies.add(allergy);
                      } else {
                        selectedAllergies.remove(allergy);
                      }
                    });
                  },
                );
              }).toList(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen[900]),
                child: Text('Upload Profile Picture', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _registerCustomer();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen[900]),
                child: Text('Register', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
