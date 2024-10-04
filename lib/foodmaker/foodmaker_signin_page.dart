import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodMakerLoginPage extends StatefulWidget {
  @override
  _FoodMakerLoginPageState createState() => _FoodMakerLoginPageState();
}

class _FoodMakerLoginPageState extends State<FoodMakerLoginPage> {
  final TextEditingController _usernameOrEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginFoodMaker() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.26:8000/api/login-food-maker'),
        body: {
          'usernameOrEmail': _usernameOrEmailController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          // Handle the success (e.g., save token, navigate)
          // Save token to local storage if needed
          // Navigate to the next page
          Navigator.pushNamed(context, '/foodmakerhomepage',arguments: {
            'identifier': result['identifier'],
            'token': result['token'], // Pass token if needed for further requests
          },);
        } else {
          _showError(result['message']);
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCAF1BC),
      appBar: AppBar(
        title: Text('Food Maker Login'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo.png', // Update with your logo path
              height: 150,
              width: 150,
            ),
            SizedBox(height: 20),

            TextField(
              controller: _usernameOrEmailController,
              decoration: InputDecoration(
                labelText: 'Username or Email',
                labelStyle: TextStyle(color: Colors.lightGreen[900]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightGreen[900]!),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
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
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _loginFoodMaker,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
