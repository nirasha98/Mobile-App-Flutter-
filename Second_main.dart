import 'package:flutter/material.dart';
import 'main.dart';
import 'CAN_Settings_page.dart';
import 'home_page.dart';
import 'widgets.dart';
import 'ble_button_click.dart';
//import 'ble_b_click_testing.dart';
import 'Debug_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ('Data Indicator'),
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatelessWidget {
  final List<Map<String, dynamic>> values = [
    {'title': 'Speed (km/h)', 'value': 60.0},
    {'title': 'Pack Voltage (V)', 'value': 48.0},
    {'title': 'Highest Cell (V)', 'value': 4.2},
    {'title': 'Lowest Cell (V)', 'value': 3.8},
    {'title': 'DC Current (A)', 'value': 10.0},
    {'title': 'Pack Temperature (°C)', 'value': 25.0},
    {'title': 'Battery Charge (%)', 'value': 25},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              iconSize: 100.0,
              color: Colors.white54,
              onPressed: () {
                // Navigate to home page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SecondPage(values: values)),
                );
              },
            ),
            Text(
              'Home',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle2
                  ?.copyWith(color: Colors.white54),
            ),
            SizedBox(height: 20.0), // Adds a vertical gap of 20 pixels
            IconButton(
              icon: Icon(Icons.settings),
              iconSize: 100.0,
              color: Colors.white54,
              onPressed: () {
                // Navigate to Bluetooth page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            Text(
              'Settings',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle2
                  ?.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
