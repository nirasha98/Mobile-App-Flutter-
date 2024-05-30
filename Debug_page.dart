//Debug Page
//This is the Second Page of the app = Debug Page
//this page includes the values and their details.At first it displays the value set,which displayed in the first page.That value set directly passed to this page and display here.
//then display the newly added variables from the third page(= Variable Settings Page.).(to navigate to third page, there is a 'add' icon button)
//Use Shared preferences package to save those values to local device ,so those newly added variables not get disappear in reloading of the page.

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_new_app/speed_calculatio_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // shared preferences package for save data in local device.
import 'dart:convert'; // for json model conerting.
import 'dart:math'; // for calculations.
import 'dataSave_model.dart'; // model to get user inputs and save them in local device by using Shared preferences.
import 'Variable_Settings_page.dart'; // third page - Variable settings page.
import 'main.dart';
import 'valueList_dataSave_model.dart';
import 'value_list_userInput_page.dart';

//for csv file
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:open_file/open_file.dart';

// to open the csv file
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

//second page - Debug Page

// clear button for each new variable

class SecondPage extends StatefulWidget {
  // list of values getting from the home page.
  //final List<Map<String, dynamic>> values;
  final List<dynamic> values;

  const SecondPage({required this.values});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  //create a list to insert user input values from Third page.(variable settings page)
  List<UserInput> userInputs = [];
  int count = 0;
  String speedValueText = '';

//essentials for shared prefferences package to save user inputs of 3rd page to our device.
  @override
  void initState() {
    super.initState();
    _loadUserInputs();
    getFormData(); // for forth page.
    handleNewValues(widget.values, userInputs);
  }

  Future<void> _loadUserInputs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('userInputs');
    if (json != null) {
      final List<dynamic> list = jsonDecode(json);
      setState(() {
        userInputs = list.map((item) => UserInput.fromMap(item)).toList();
      });
    }
  }

  Future<void> _saveUserInputs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(userInputs.map((item) => item.toMap()).toList());
    await prefs.setString('userInputs', json);
  }

  void _addUserInput(UserInput userInput) async {
    setState(() {
      userInputs.add(userInput);
    });
    await _saveUserInputs();
    await _loadUserInputs(); // Reload user inputs after adding a new input

    handleNewValues(widget.values, userInputs);
  }

// for forth page

  void getFormData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String rpm = prefs.getString('rpm') ?? '';
    String packVoltage = prefs.getString('packVoltage') ?? '';
    String highestCell = prefs.getString('highestCell') ?? '';
    String lowestCell = prefs.getString('lowestCell') ?? '';
    String dcCurrent = prefs.getString('dcCurrent') ?? '';
    String packTemperature = prefs.getString('packTemperature') ?? '';
    String batteryCharge = prefs.getString('batteryCharge') ?? '';

    setState(() {
      widget.values[0] = rpm;
      widget.values[1] = packVoltage;
      widget.values[2] = highestCell;
      widget.values[3] = lowestCell;
      widget.values[4] = dcCurrent;
      widget.values[5] = packTemperature;
      widget.values[6] = batteryCharge;
    });
  }

  void saveFormData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('rpm', widget.values[0]);
    prefs.setInt('packVoltage', widget.values[1]);
    prefs.setInt('highestCell', widget.values[2]);
    prefs.setInt('lowestCell', widget.values[3]);
    prefs.setInt('dcCurrent', widget.values[4]);
    prefs.setInt('packTemperature', widget.values[5]);
    prefs.setInt('batteryCharge', widget.values[6]);
  }

  // for csv file

  void saveDataAsCSV(List<dynamic> values, List<UserInput> userInput) async {
    final directory = await getExternalStorageDirectory();
    final documentsPath = '${directory?.path}/Documents';

    // Create the "Documents" directory if it doesn't exist
    await Directory(documentsPath).create(recursive: true);

    // Create a new file in the Documents directory
    final file = File('$documentsPath/csv_report_final.csv');
    bool fileExists = await file.exists();

    // Open the file in append mode
    final sink = file.openWrite(mode: FileMode.append);

    // final row = [
    //   DateTime.now().toString(),
    //   ...values.map((value) => value.toString())
    // ];

    if (!fileExists) {
      // Create the CSV file with headers if it doesn't exist
      final headers = [
        'current time',
        'rpm',
        'pack voltage',
        'highest voltage',
        'lowest voltage',
        'dc current',
        'pack temp',
        'battery charge',
        'empty',
      ];

      final titles = userInput.map((input) => input.title);
      final updatedHeaders = [...headers, ...titles];
      sink.writeln(updatedHeaders.join(','));
    } else {
      final headers = [
        'current time',
        'rpm',
        'pack voltage',
        'highest voltage',
        'lowest voltage',
        'dc current',
        'pack temp',
        'battery charge',
        'empty',
      ];
      final newTitles = userInput.map((input) => input.title);

      print(newTitles);
      // append newTitles to the headers row
      final existingContent = await file.readAsString();
      final lines = existingContent.split('\n');
      if (lines.isNotEmpty) {
        //lines[0] = headers.join(',') + ',' + newTitles.join(',');
        lines.removeAt(0);
        final newLine = headers.join(',') + ',' + newTitles.join(',');
        lines.insert(0, newLine);

        //final updatedContent = '${lines.join('\n')}\n${row.join(',')}';
        //final updatedContent2 = lines.sublist(0, lines.length - 1).join('\n');

        final updatedContent = lines.join('\n');
        await file.writeAsString(updatedContent);
        lines.add("");
      }
      //final updatedContent = lines.join('\n');
    }

    //Create a new row with the current time and values
    final row = [
      DateTime.now().toString(),
      ...values.map((value) => value.toString())
    ];

    // Get the titles of newly added userInput elements
    final newTitles = userInput.map((input) => input.title);
    print(newTitles);

    // Add values from the `userInput` list
    row.addAll(userInput.map((input) {
      if (newTitles.contains(input.title)) {
        return input.value.toString();
      } else {
        return '';
      }
    }));

    // Write the row to the CSV file
    //sink.writeln(row.join(','));
    final existingContent2 = await file.readAsString();
    final updatedContent2 = existingContent2 + '\n' + row.join(',');
    await file.writeAsString(updatedContent2);

    // Close the file
    await sink.flush();
    await sink.close();
  }

  void handleNewValues(List<dynamic> values, List<UserInput> userInputs) {
    // Call your desired function here with the updated values and userInputs
    saveDataAsCSV(values, userInputs);
  }

  List<dynamic> _values = [];
  List<UserInput> _userInputs = [];

  void setValues(List<dynamic> values) {
    _values = values;
    handleNewValues(_values, _userInputs);
  }

  void setUserInputs(List<UserInput> userInputs) {
    _userInputs = userInputs;
    handleNewValues(_values, _userInputs);
  }

//new
  Widget _buildUserInputListTile(UserInput userInput) {
    if (userInput.type == 'Value') {
      return Column(
        children: [
          ListTile(
            title: Text(userInput.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userInput.value),
                SizedBox(height: 4),
                //Text('Type: ${userInput.type}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThirdPage(userInput: userInput),
                      ),
                    );
                    if (result != null &&
                        result['title'] != null &&
                        result['value'] != null &&
                        result['type'] != null) {
                      final updatedUserInput = UserInput(
                          title: result['title'],
                          value: result['value'],
                          type: result['type'],
                          CanId: result['canId'],
                          packet: result['packet'],
                          byteindex: result['byteindex'],
                          bitindex: result['bitindex'],
                          highbyteindex: result['highbyteindex'],
                          lowbyteindex: result['lowbyteindex'],
                          datatype: result['datatype']);
                      setState(() {
                        userInputs[userInputs.indexOf(userInput)] =
                            updatedUserInput;
                      });
                      await _saveUserInputs();
                    }
                  },
                ), // Edit icon and its action
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () async {
                    setState(() {
                      userInputs.remove(userInput);
                    });
                    await _saveUserInputs();
                  },
                ),
              ],
            ),
          ),
          Divider(),
        ],
      );
    } else if (userInput.type == 'Flag') {
      return Column(
        children: [
          ListTile(
            title: Text(userInput.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userInput.value),
                SizedBox(height: 4),
                //Text('Type: ${userInput.type}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThirdPage(userInput: userInput),
                      ),
                    );
                    if (result != null &&
                        result['title'] != null &&
                        result['value'] != null &&
                        result['type'] != null) {
                      final updatedUserInput = UserInput(
                          title: result['title'],
                          value: result['value'],
                          type: result['type'],
                          CanId: result['canId'],
                          packet: result['packet'],
                          byteindex: result['byteindex'],
                          bitindex: result['bitindex'],
                          highbyteindex: result['highbyteindex'],
                          lowbyteindex: result['lowbyteindex'],
                          datatype: result['datatype']);
                      setState(() {
                        userInputs[userInputs.indexOf(userInput)] =
                            updatedUserInput;
                      });
                      await _saveUserInputs();
                    }
                  },
                ), // Edit icon and its action
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () async {
                    setState(() {
                      userInputs.remove(userInput);
                    });
                    await _saveUserInputs();
                  },
                ),
              ],
            ),
          ),
          Divider(),
        ],
      );
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<UserInput> valueInputs =
        userInputs.where((input) => input.type == 'Value').toList();
    final List<UserInput> flagInputs =
        userInputs.where((input) => input.type == 'Flag').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              saveDataAsCSV(widget.values, userInputs);
            },
          ),
        ],
      ),
      // AppBar(
      //   title: Text('Debug Page'),
      // ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //SizedBox(height: 16.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.values.length,
                    itemBuilder: (context, index) {
                      final valueItem = widget.values[index];
                      String title = '';

                      if (index == 0) {
                        if (count < 1) {
                          title = 'RPM';
                        } else {
                          title = 'Speed (km/h)';
                        }
                      } else if (index == 1) {
                        title = 'Pack Voltage (V)';
                      } else if (index == 2) {
                        title = 'Highest Cell (V)';
                      } else if (index == 3) {
                        title = 'Lowest Cell (V)';
                      } else if (index == 4) {
                        title = 'DC Current (A)';
                      } else if (index == 5) {
                        title = 'Pack Temperature (°C)';
                      } else if (index == 6) {
                        title = 'Battery Charge (%)';
                      }

                      if (index != 0) {
                        return ListTile(
                          title: Text(title, style: TextStyle(fontSize: 14.0)),
                          subtitle: Text(valueItem.toString()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ForthPage(
                                              initialValue:
                                                  widget.values[index],
                                              index: index,
                                              TiTle: title,
                                            )),
                                  ).then((Updated_values) {
                                    if (Updated_values != null) {
                                      setState(() {
                                        // Update the value in the list
                                        //widget.values[index] = Updated_values[1];
                                        //title = Updated_values[0];
                                        widget.values[index] =
                                            Updated_values['updatedValue'];
                                        //title = Updated_values['updatedTitle'];

                                        saveFormData();

                                        // Update the value in the valueList (if needed)
                                      });
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        return ListTile(
                          title: Text(title, style: TextStyle(fontSize: 14.0)),
                          subtitle: Text(valueItem.toString()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SpeedPage(
                                            initialValue: widget.values[index],
                                            index: index,
                                            TiTle: "Speed"
                                            //TiTle: title,
                                            )),
                                  ).then((Updated_values) {
                                    if (Updated_values != null) {
                                      setState(() {
                                        // Update the value in the list
                                        //widget.values[index] = Updated_values[1];
                                        //title = Updated_values[0];
                                        widget.values[index] =
                                            Updated_values['updatedValue'];
                                        // title = Updated_values['updatedTitle'];
                                        speedValueText =
                                            'Speed = ${Updated_values['updatedTitle']}';

                                        count = count + 1;

                                        saveFormData();

                                        print(
                                            'Updated Title: $speedValueText'); // Print the updated title

                                        print('Updated Title: $title');
                                      });
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  if (widget.values.isEmpty)
                    const Text('Still Loading Data...'),
                  // for (var value in widget.values)
                  //   ListTile(
                  //     title: Text(value['title']),
                  //     subtitle: Text('${value['value']}'),
                  //   ),
                  SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: valueInputs.length,
                    itemBuilder: (context, index) {
                      final userInput = valueInputs[index];
                      return _buildUserInputListTile(userInput);
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: flagInputs.length,
                itemBuilder: (context, index) {
                  final userInput = flagInputs[index];
                  return _buildUserInputListTile(userInput);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ThirdPage()),
          ); // displaying data receiving from third page - user inputs.
          if (result != null &&
              result['title'] != null &&
              result['value'] != null &&
              result['type'] != null &&
              result['canId'] != null) {
            final userInput = UserInput(
                title: result['title'],
                value: result['value'],
                type: result['type'],
                CanId: result['canId'],
                packet: result['packet'],
                byteindex: result['byteindex'],
                bitindex: result['bitindex'],
                highbyteindex: result['highbyteindex'],
                lowbyteindex: result['lowbyteindex'],
                datatype: result['datatype']);
            _addUserInput(userInput);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
