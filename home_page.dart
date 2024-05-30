//Home Page(Data Indicator)
//This dart file includes the Home page of the app.It displays a list of values received through bluetooth Low Energy.
//App bar includes a settings icon to navigate to CAN Settings Page.
//finally includes a arrow icon to navigate to Second page - Debug Page.

import 'package:flutter/material.dart';
//import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Shared preferences package for save data in local device.
import 'dart:math'; // for calculations.
import 'dataSave_model.dart'; // model to get user inputs and save them in local device by using Shared preferences.
import 'dart:convert'; // for json model conerting.

// needed lists and functions for later calculations
import 'can_message_decode.dart'; // include CAN messages list and function for calculating CAN value.
import 'flag_bit_decode.dart'; // include CAN messages list and funtion to output the requested flag bit.

//importing Pages of the App.
import 'CAN_Settings_page.dart'; // CAN Settings page
import 'Variable_Settings_page.dart'; // third page - Variable Settings page.
import 'Debug_page.dart'; // second page - Debug page.
import 'package:collection/collection.dart';

//Home Page

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: ('Data Indicator'),
//       home: HomePage(),
//     );
//   }
// }

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> values = [
    {'title': 'Speed (km/h)', 'value': 60.0},
    {'title': 'Pack Voltage (V)', 'value': 48.0},
    {'title': 'Highest Cell (V)', 'value': 4.2},
    {'title': 'Lowest Cell (V)', 'value': 3.8},
    {'title': 'DC Current (A)', 'value': 10.0},
    {'title': 'Pack Temperature (°C)', 'value': 25.0},
    {'title': 'Battery Charge (%)', 'value': 25},
  ]; // the values list
  // need to pass value list from device Screen page in ble_button_click page.

//build method is correct
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page'), actions: [
        // setting icon in app bar and action for pressing it
        // IconButton(
        //   icon: Icon(Icons.settings),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) =>
        //               SettingsPage()), // navigate to settings page
        //     );
        //   },
        // ),
      ]),
      body: ListView.builder(
        itemCount: values.length,
        itemBuilder: (context, index) {
          final value = values[index];
          return index == 0
              ? Container(
                  child: ListTile(
                    title: Text(
                      value['title'],
                      style: TextStyle(fontSize: 20.0),
                    ),
                    subtitle: Text(
                      '${value['value']}',
                      style: TextStyle(fontSize: 44),
                    ),
                  ), // first item of the list (=speed) display in larger font size.
                  padding: EdgeInsets.all(16.0), // add padding to the container
                )
              : ListTile(
                  title: Text(value[
                      'title']), // display the remaining items of the list in home page.
                  subtitle: Text('${value['value']}'),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // button to navigate to the Debug Page
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SecondPage(
                  values:
                      values), // button press action for navigate to Second page - Debug page
            ),
          );
        },
        child: Icon(Icons.arrow_forward), // arrow icon towards second page.
      ),
    );
  }
}
