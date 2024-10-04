import 'package:flutter/material.dart';
import 'customer/customer_sign_up_page.dart';
import 'foodmaker/food_maker_sign_up_page.dart';

class RegistrationSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCAF1BC), // Updated background color
      appBar: AppBar(
        title: Text(
          'User Registration Selection',
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check orientation
          bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isLandscape) SizedBox(height: 50), // Spacing at the top (only for portrait)
                  Image.asset(
                    'assets/images/logo.png',
                    height: isLandscape
                        ? constraints.maxHeight * 0.3 // Larger size for landscape
                        : constraints.maxHeight * 0.2, // Smaller size for portrait
                  ),
                  SizedBox(height: 30), // Spacing between the logo and text
                  Text(
                    'Register As',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightGreen[900], // Darker green text for better contrast
                    ),
                  ),
                  SizedBox(height: 30), // Spacing between text and buttons
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CustomerSignUpPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.lightGreen[900],
                                padding: EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                side: BorderSide(
                                  color: Colors.lightGreen[900]!,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                'Customer',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20), // Spacing between buttons
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => FoodMakerSignUpPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.lightGreen[900],
                                padding: EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                side: BorderSide(
                                  color: Colors.lightGreen[900]!,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                'Food Maker',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLandscape) SizedBox(height: 50), // Bottom spacing for portrait
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
