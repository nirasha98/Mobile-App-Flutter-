//Variable Settings Page
//third page of the app, inclues fields to get user inputs.Some are text or numerical inputs.some are drop down menus.
//take user inputs, do some calculations and pass relevant data to the Second page(Debug Pag) to make them display.('Add' icon button).

import 'package:flutter/material.dart';
import 'package:flutter_new_app/dataSave_Value_Model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // shared preferences package for save data in local device.
import 'can_message_decode.dart'; // include CAN messages list and function for calculating CAN value.
import 'dataSave_model.dart';
import 'dataSave_Value_Model.dart';
import 'flag_bit_decode.dart'; // include CAN messages list and funtion to output the requested flag bit.
import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

//third page - Variable Settings Page
// class ThirdPage extends StatefulWidget {
//   @override
//   _ThirdPageState createState() => _ThirdPageState();
// }

class ThirdPage extends StatefulWidget {
  final UserInput? userInput;
  //final UserInputValue? userInputValue;

  const ThirdPage({Key? key, this.userInput}) : super(key: key);

  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = path.join(dbPath, 'your_database.db');
    return await openDatabase(dbFilePath,
        version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_inputs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        canId TEXT,
        type TEXT,
        packet INTEGER,
        byteIndex TEXT,
        bitIndex TEXT,
        highByteIndex TEXT,
        lowByteIndex TEXT,
        dataType TEXT
      )
    ''');
  }

  Future<int> insertUserInput(UserInput userInput) async {
    final db = await instance.database;
    return await db.insert('user_inputs', userInput.toMap());
  }

  Future<List<UserInput>> getUserInputs() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('user_inputs');
    return List.generate(maps.length, (i) => UserInput.fromMap(maps[i]));
  }
}

class _ThirdPageState extends State<ThirdPage> {
  final _titleController =
      TextEditingController(); // for variable name input field
  final _valueController = TextEditingController(); // for CAN id input field
  String? dropdownValueFlag; // checking variable type - value or flag
  bool showExtraFieldsValue = false; // fields showing for Value
  bool showExtraFieldsFlag = false; // fields showing for flag
  String? dropdownDataType; // for drop down menu of data type selection

  int dropdownPacket = 0; // for packet slecttion drop down menu
  final _HighByteIndexController =
      TextEditingController(); // to get user input as High byte index
  final _LowByteIndexController =
      TextEditingController(); // to get user input as low byte index
  final _ByteIndexController = TextEditingController();
  final _BitIndexController = TextEditingController();
  // for validate fields
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.userInput != null) {
      _titleController.text = widget.userInput!.title;
      _valueController.text = widget.userInput!.CanId;
      dropdownValueFlag = widget.userInput!.type;
      dropdownPacket = widget.userInput!.packet;
      _ByteIndexController.text = widget.userInput!.byteindex!;
      _BitIndexController.text = widget.userInput!.bitindex!;
      _LowByteIndexController.text = widget.userInput!.lowbyteindex!;
      _HighByteIndexController.text = widget.userInput!.highbyteindex!;
      dropdownDataType = widget.userInput!.datatype;
    }
  }

  void dispose() {
    _titleController.dispose();
    _valueController.dispose();

    super.dispose();
  } // for clearing values in reload of page.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Variable Settings'),
        ), // app bar of third page - Variable settings page.
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'eg: Temperature',
                        labelText: 'Name of the New Variable',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the name of the variable';
                        }
                        return null;
                      }, // validator for inform user to fill the required field
                    ), // first user entery field - Variable Name
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _valueController,
                      decoration: InputDecoration(
                        hintText: "eg: 0x123",
                        labelText: 'CAN Id',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the CAN Id';
                        }
                        return null;
                      }, // validator for inform user to fill the required fields
                    ), // second user entery field - CAN Id
                    SizedBox(height: 16.0),

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '  Variable Type:',
                            style: TextStyle(fontSize: 16),
                          ),
                          DropdownButton<String>(
                            value: dropdownValueFlag,
                            hint: Text('Select a Type'),
                            onChanged: (String? value) {
                              setState(() {
                                dropdownValueFlag = value;
                                if (value == 'Value') {
                                  showExtraFieldsValue = true;
                                } else {
                                  showExtraFieldsValue = false;
                                }
                                if (value == 'Flag') {
                                  showExtraFieldsFlag = true;
                                } else {
                                  showExtraFieldsFlag = false;
                                }
                              });
                            },
                            items: [
                              DropdownMenuItem<String>(
                                value: 'Value',
                                child: Text('Value'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Flag',
                                child: Text('Flag'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ), // 3rd user entry field as a dropdown menu - Variable type
                    // if user select variable type as Value, then another set of hidden fields become visible in below.
                    if (showExtraFieldsValue) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '  Packet :',
                              style: TextStyle(fontSize: 16),
                            ),
                            DropdownButton<String>(
                              value: dropdownPacket.toString(),
                              hint: Text('Select packet Id'),
                              onChanged: (String? value) {
                                setState(() {
                                  dropdownPacket = int.parse(value!);
                                });
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: '-1',
                                  child: Text('None'),
                                ),
                                for (int i = 0; i <= 20; i++)
                                  DropdownMenuItem<String>(
                                    value: i.toString(),
                                    child: Text(i.toString()),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ), // user entry as a drop down menu for Packet Id.
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: TextFormField(
                                  controller: _HighByteIndexController,
                                  decoration: InputDecoration(
                                    hintText: 'Index of High byte',
                                    labelText: 'Index of High byte',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter index of High Byte';
                                    }
                                    return null;
                                  }, // validator for inform user to fill the required fields
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ), // user entry for index of high byte.
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: TextFormField(
                                  controller: _LowByteIndexController,
                                  decoration: InputDecoration(
                                    hintText: 'Index of Low byte',
                                    labelText: 'Index of Low byte',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter index of Low Byte';
                                    }
                                    return null;
                                  }, // validator for inform user to fill the required fields
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ), // user entry for index of low byte
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '  Data Type :',
                              style: TextStyle(fontSize: 16),
                            ),
                            DropdownButton<String>(
                              value: dropdownDataType,
                              hint: Text('Select a data type'),
                              onChanged: (String? value) {
                                setState(() {
                                  dropdownDataType = value!;
                                });
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'uint_8',
                                  child: Text('uint_8'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'uint_16',
                                  child: Text('uint_16'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'int_8',
                                  child: Text('int_8'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'int_16',
                                  child: Text('int_16'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'float_32',
                                  child: Text('float_32'),
                                ),
                              ],
                            ), // drop down menu for user entry of data type .
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // checking for empty fields and inform user (validator for inform user to fill the required fields)
                                if (_formKey.currentState!.validate()) {
                                  // form is validated
                                  // do something with the form data

                                  final title =
                                      _titleController.text; // Variable Name

                                  String input1 = '';
                                  String input = _valueController.text;
                                  if (input.startsWith('0x')) {
                                    input1 = input.substring(2);
                                  }
                                  int canId =
                                      int.parse(input1, radix: 16); // CAN Id

                                  String highByteIndexString =
                                      _HighByteIndexController.text;
                                  int highByteIndex =
                                      int.parse(_HighByteIndexController.text) -
                                          1; // index of  highbyte

                                  String lowByteIndexString =
                                      _LowByteIndexController.text;
                                  int lowByteIndex =
                                      int.parse(_LowByteIndexController.text) -
                                          1; // index of bit

                                  // call function to calculate the bit value

                                  final intValue = calculateCANValue(
                                      canId,
                                      dropdownPacket,
                                      highByteIndex,
                                      lowByteIndex,
                                      dropdownDataType!);

                                  String value = intValue
                                      .toString(); // converting the calculated value to a string,to display in the Debug page.

                                  if (title.isNotEmpty && value.isNotEmpty) {
                                    final userInput = UserInput(
                                      title: title,
                                      value: value,
                                      type: dropdownValueFlag!,
                                      packet: dropdownPacket,
                                      CanId: input,
                                      highbyteindex: highByteIndexString,
                                      lowbyteindex: lowByteIndexString,
                                      bitindex: '',
                                      byteindex: '',
                                      datatype: dropdownDataType,
                                    );
                                    Navigator.pop(context, userInput.toMap());
                                  }

                                  print('Form validated!');
                                }
                              },
                              child: Text('Add'),
                            ),
                          ),
                        ],
                      )
                    ],
                    // below fields become visible, after selecting the variable type as Flag by user in 3rd user entry field.
                    if (showExtraFieldsFlag) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '  Packet :',
                              style: TextStyle(fontSize: 16),
                            ),
                            DropdownButton<String>(
                              value: dropdownPacket.toString(),
                              hint: Text('Select packet Id'),
                              onChanged: (String? value) {
                                setState(() {
                                  dropdownPacket = int.parse(value!);
                                });
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: '-1',
                                  child: Text('None'),
                                ),
                                for (int i = 0; i <= 20; i++)
                                  DropdownMenuItem<String>(
                                    value: i.toString(),
                                    child: Text(i.toString()),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          controller: _ByteIndexController,
                          decoration: InputDecoration(
                            hintText: '  Index of the Byte: ',
                            labelText: '  Index of the Byte: ',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter index of Byte';
                            }
                            return null;
                          }, // validator for inform user to fill the required fields
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          controller: _BitIndexController,
                          decoration: InputDecoration(
                            hintText: '  Index of the Bit: ',
                            labelText: '  Index of the Bit: ',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter index of Bit';
                            }
                            return null;
                          }, // validator for inform user to fill the required fields
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                              child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final title = _titleController.text;

                                String input1 = '';
                                String input = _valueController.text;
                                if (input.startsWith('0x')) {
                                  input1 = input.substring(2);
                                }
                                int canId = int.parse(input1, radix: 16);

                                String byteIndexString =
                                    _ByteIndexController.text;
                                int byteIndex =
                                    int.parse(_ByteIndexController.text) - 1;

                                String bitIndexString =
                                    _BitIndexController.text;
                                int bitIndex =
                                    int.parse(_BitIndexController.text);

                                final intValue = getBitValue(
                                    canId, dropdownPacket, byteIndex, bitIndex);

                                String value = intValue.toString();

                                if (title.isNotEmpty && value.isNotEmpty) {
                                  final userInput = UserInput(
                                    title: title,
                                    value: value,
                                    type: dropdownValueFlag!,
                                    packet: dropdownPacket,
                                    CanId: input,
                                    byteindex: byteIndexString,
                                    bitindex: bitIndexString,
                                    highbyteindex: '',
                                    lowbyteindex: '',
                                    datatype: '',
                                  );

                                  Navigator.pop(context, userInput.toMap());
                                }
                              }
                              print('Form validated!');
                            },
                            child: Text('Add'),
                          )

                              // child: ElevatedButton(
                              //   onPressed: () {
                              //     //checking for empty fields and inform user to fill them.(validator for inform user to fill the required fields.)
                              //     if (_formKey.currentState!.validate()) {
                              //       final title =
                              //           _titleController.text; // Variable Name

                              //       String input = _valueController.text;
                              //       if (input.startsWith('0x')) {
                              //         input = input.substring(2);
                              //       } // check hex type CAN id.
                              //       int canId =
                              //           int.parse(input, radix: 16); // CAN Id

                              //       int byteIndex =
                              //           int.parse(_ByteIndexController.text) -
                              //               1; // index of  byte
                              //       int bitIndex = int.parse(
                              //           _BitIndexController.text); // index of bit

                              //       // call function to calculate the bit value
                              //       final intValue = getBitValue(canId,
                              //           dropdownPacket, byteIndex, bitIndex);

                              //       String value = intValue
                              //           .toString(); // converting the calculated value to a string,to display in the Debug page.

                              //       if (title.isNotEmpty && value.isNotEmpty) {
                              //         Navigator.pop(
                              //           context,
                              //           {
                              //             'title': title,
                              //             'value': value,
                              //             'type':
                              //                 dropdownValueFlag // set of displaying values in Debug Page.
                              //           },
                              //         );
                              //       }
                              //     }
                              //     print('Form validated!');
                              //   },
                              //   child: Text('Add'),
                              // ),
                              ),
                        ],
                      )
                      // ElevatedButton(
                      //   onPressed: () {
                      //     final title = _titleController.text; // Variable Name

                      //     String input = _valueController.text;
                      //     if (input.startsWith('0x')) {
                      //       input = input.substring(2);
                      //     }
                      //     int canId = int.parse(input, radix: 16); // CAN Id

                      //     int byteIndex = int.parse(_ByteIndexController.text) -
                      //         1; // index of  byte
                      //     int bitIndex =
                      //         int.parse(_BitIndexController.text); // index of bit

                      //     // call function to calculate the bit value

                      //     final intValue = getBitValue(
                      //         canId, dropdownPacket, byteIndex, bitIndex);

                      //     String value = intValue
                      //         .toString(); // converting the calculated value to a string,to display in the Debug page.

                      //     if (title.isNotEmpty && value.isNotEmpty) {
                      //       Navigator.pop(
                      //         context,
                      //         {
                      //           'title': title,
                      //           'value': value,
                      //           'type':
                      //               dropdownValueFlag // set of displaying values in Debug Page.
                      //         },
                      //       );
                      //     }
                      //   },
                      //   child: Text('Add'),
                      // ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.pop(context);
                      //   },
                      //   child: Text('Cancel'),
                      // ),
                    ],
                  ],
                ),
              )),
        ));
  }
}
