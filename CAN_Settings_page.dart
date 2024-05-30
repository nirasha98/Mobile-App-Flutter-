// CAN Settings Page.
// includes CAN speed and relevant data.
import 'package:flutter/material.dart';
//import 'BLE_page.dart';
import 'main.dart';
//import 'ble_b_click_testing.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'main.dart';

// new 1 at 10.00 -default
class SettingsPage extends StatelessWidget {
  final double canSpeed = 500;
  final double otherData = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView.builder(
        itemCount: 3, // Increase the item count by 1 for the button
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListTile(
              title: Text(
                'CAN Speed: $canSpeed',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            return ListTile(
              title: Text(
                'Other Data: $otherData',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
        },
      ),
    );
  }
}
