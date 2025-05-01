import 'package:flutter/material.dart'; //Core library for UI, designing
import 'package:http/http.dart' as http; // To make http request to server
import 'dart:convert'; // Convert data to JSON format
import 'package:geolocator/geolocator.dart'; // For getting location

// Main Function that runs MyApp class
void main() {
  runApp(MyApp());
}

// Define MyApp class
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

// Logic of app
class _MyAppState extends State<MyApp> {
  String message = "Location Not Sent"; // INitial display on screen

  // Function to get the current GPS location
  Future<Position> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if GPS is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  // Function to send location to FastAPI
  Future<void> _sendLocation() async {
    try {
      Position position = await _getLocation();
      double latitude = position.latitude;
      double longitude = position.longitude;

      var url = Uri.parse(
        'http://192.168.100.83:8000/update-location/',
      ); // Backend API URL
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"latitude": latitude, "longitude": longitude}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        print("Location sent successfully!");
      } else {
        print("Failed to send location");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  // GUI of app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("GPS Tracker")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendLocation,
                child: Text("Send Location"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
