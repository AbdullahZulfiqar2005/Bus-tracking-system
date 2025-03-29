import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart'; // For getting location

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String message = "Location Not Sent";

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
        'http://192.168.100.76:8000/update-location/',
      ); // Backend API URL
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"latitude": latitude, "longitude": longitude}),
      );

      setState(() {
        message = response.body;
      });
    } catch (e) {
      setState(() {
        message = "Error: $e";
      });
    }
  }

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
