import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:camera/camera.dart';

class ContactServicePage extends StatefulWidget {
  const ContactServicePage({Key? key}) : super(key: key);

  @override
  _ContactServicePageState createState() => _ContactServicePageState();
}

class _ContactServicePageState extends State<ContactServicePage> {
  int _batteryLevel = 0;
  final Battery _battery = Battery(); // Initialize the battery instance
  List<CameraDescription> _cameras = [];
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _getBatteryLevel(); // Call to get battery level
    _initializeCamera(); // Initialize the camera
  }

  Future<void> _getBatteryLevel() async {
    try {
      final int batteryLevel = await _battery.batteryLevel; // Get battery level
      setState(() {
        _batteryLevel = batteryLevel; // Update battery level state
      });
    } catch (e) {
      print("Error getting battery level: $e"); // Print error if any
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras.first, ResolutionPreset.high);

    try {
      await _controller!.initialize();
    } catch (e) {
      print("Error initializing camera: $e");
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _takePicture() async {
    if (_controller != null) {
      try {
        final image = await _controller!.takePicture();
        // Handle the image captured (e.g., save it or upload it)
        print('Image captured: ${image.path}');
      } catch (e) {
        print('Error capturing image: $e');
      }
    }
  }

  // Method to launch email
  void _launchEmail() async {
    const email = 'support@example.com'; // Replace with your support email
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Request', // Optional
    );

    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  // Method to launch phone
  void _launchPhone() async {
    const phoneNumber = '1234567890'; // Replace with your support phone number
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  // Method to launch SMS
  void _launchSMS() async {
    const smsNumber = '1234567890'; // Replace with your support SMS number
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: smsNumber,
      query: 'body=Hello, I need help with...', // Optional
    );

    if (await canLaunch(smsUri.toString())) {
      await launch(smsUri.toString());
    } else {
      throw 'Could not launch $smsUri';
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Support'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Contact us via the following methods:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Battery Level: $_batteryLevel%'), // Display battery level
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _launchEmail,
              icon: const Icon(Icons.email),
              label: const Text('Send an Email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _launchPhone,
              icon: const Icon(Icons.phone),
              label: const Text('Make a Phone Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _launchSMS,
              icon: const Icon(Icons.message),
              label: const Text('Send an SMS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera),
              label: const Text('Capture Image for Complaint'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            if (_controller != null && _controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
          ],
        ),
      ),
    );
  }
}