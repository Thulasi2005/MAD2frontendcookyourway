import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCAF1BC), // Light green background color
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50), // Add some spacing at the top
              Image.asset(
                'assets/images/logo.png',
                height: MediaQuery.of(context).size.height * 0.3, // Make the image size responsive
              ),
              SizedBox(height: 50), // Add spacing between the image and buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/customersignIn'); // Navigate to donor sign-in page
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20), // Increase button padding
                    backgroundColor: Colors.white, // Change button background color to white
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                      side: BorderSide(color: Colors.green[900]!), // Border color to match the text
                    ),
                  ),
                  child: Text(
                    'Customers',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20, // Increase font size
                      color: Colors.green[900], // Change text color to green
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/foodmakersignIn'); // Navigate to elderly home sign-in page
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20), // Increase button padding
                    backgroundColor: Colors.white, // Change button background color to white
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                      side: BorderSide(color: Colors.green[900]!), // Border color to match the text
                    ),
                  ),
                  child: Text(
                    'Food Makers',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20, // Increase font size
                      color: Colors.green[900], // Change text color to green
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/registerselection'); // Navigate to the registration selection page
                },
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20, // Increase font size
                    color: Colors.lightGreen[900], // Ensure the text is visible
                  ),
                ),
              ),
              SizedBox(height: 50), // Add some spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
