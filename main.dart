import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Debug_page.dart';
import 'CAN_Settings_page.dart';

import 'widgets.dart';

// new for string
import 'dart:typed_data';

// class DataParser {
//   static List<String> parseUint16ToString(List<int> value) {
//     final parsedValues = <String>[];
//     final data = Uint8List.fromList(value);
//     final length = data.length;

//     for (var i = 0; i < length - 1; i += 2) {
//       final uint16Value = (data[i + 1] << 8) | data[i];
//       final stringValue = uint16Value.toString();
//       parsedValues.add(stringValue);
//     }

//     return parsedValues;
//   }
// }
//new end

void main() {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request().then((status) {
      runApp(const FlutterBlueApp());
    });
  } else {
    runApp(const FlutterBlueApp());
  }
} // getting permissions

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: key, // Add this line to assign the key
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
        stream: FlutterBluePlus.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return const FindDevicesScreen();
          }
          return BluetoothOffScreen(state: state);
        },
      ),
    );
  }
} // checking the bluetooth state(on/off) and pass to the relevant page.

//if bluetooth is off, navigate to this page to on the bluetooth
class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 170.0,
              color: Colors.white54,
              //color: Colors.lightBlue,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle2
                  ?.copyWith(color: Colors.white54),
            ),
            ElevatedButton(
              child: const Text('TURN ON'),
              onPressed: Platform.isAndroid
                  ? () => FlutterBluePlus.instance.turnOn()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

//if bluetooth is on, navigate to this page to scan available devices and to connect
class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
        actions: [
          ElevatedButton(
            child: const Text('TURN OFF'),
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              onPrimary: Colors.white,
            ),
            onPressed: Platform.isAndroid
                ? () => FlutterBluePlus.instance.turnOff()
                : null,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => FlutterBluePlus.instance
            .startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(const Duration(seconds: 2))
                    .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((d) => ListTile(
                            title: Text(d.name),
                            subtitle: Text(d.id.toString()),
                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: d.state,
                              initialData: BluetoothDeviceState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {
                                  return ElevatedButton(
                                    child: const Text('OPEN'),
                                    onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DeviceScreen(device: d))),
                                  );
                                }
                                return Text(snapshot.data.toString());
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.instance.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map(
                        // (r) => ScanResultTile(
                        //   result: r,
                        //   onTap: () => Navigator.of(context)
                        //       .push(MaterialPageRoute(builder: (context) {
                        //     r.device.connect();
                        //     return DeviceScreen(device: r.device);
                        //   })),
                        // ),

                        (r) => ScanResultTile(
                          result: r,
                          onTap: () {
                            r.device
                                .connect(); // Connect to the Bluetooth device
                            // Perform any other desired actions after connecting
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: const Icon(Icons.stop),
              onPressed: () => FlutterBluePlus.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () => FlutterBluePlus.instance
                    .startScan(timeout: const Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

//page to display read values

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
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
  List<int> value = [];
  //List<int> value = List<int>.filled(7, 0);

  String receivedMessage = '';
  bool isReading = false; // Flag to track read operation

  @override
  void initState() {
    super.initState();
    _setupCharacteristicListener();
  }

  void _setupCharacteristicListener() {
    final desiredServiceUuid = Guid('000000FF-0000-1000-8000-00805F9B34FB');
    final desiredCharacteristicUuid =
        Guid('0000FF01-0000-1000-8000-00805F9B34FB');
    final desiredDescriptorUuid = Guid('00002902-0000-1000-8000-00805F9B34FB');

    widget.device.state.listen((BluetoothDeviceState state) {
      if (state == BluetoothDeviceState.connected) {
        widget.device.discoverServices().then((services) async {
          final desiredService = services.firstWhereOrNull(
            (service) => service.uuid == desiredServiceUuid,
          );
          print('\n\n');
          print('Desired service found');

          if (desiredService != null) {
            final desiredCharacteristic =
                desiredService.characteristics.firstWhereOrNull(
              (characteristic) =>
                  characteristic.uuid == desiredCharacteristicUuid,
            );
            print('\n\n');
            print('Desired characteristic found');

            if (desiredCharacteristic != null) {
              final desiredDescriptor =
                  desiredCharacteristic.descriptors.firstWhereOrNull(
                (descriptor) => descriptor.uuid == desiredDescriptorUuid,
              );
              print('\n\n');
              print('Desired descriptor  found');

              // if (desiredDescriptor != null) {
              //   await desiredDescriptor
              //       .write([0x01, 0x00]); // Enable notifications

              //   await desiredCharacteristic
              //       .setNotifyValue(true); // Set up notification listener

              //   desiredCharacteristic.value.listen((data) {
              //     setState(() {
              //       // Handle the received value

              //       //valueList.add(value);
              //       print('\n\n');
              //       print(data);
              //       value = data;
              //       print('\n\n');
              //       print(value);
              //     });
              //   });
              // }
              if (desiredDescriptor != null) {
                await desiredDescriptor
                    .write([0x01, 0x00]); // Enable notifications

                await desiredCharacteristic
                    .setNotifyValue(true); // Set up notification listener

                desiredCharacteristic.value.listen((data) {
                  setState(() {
                    // Handle the received value

                    // Assuming the tx_buffer size is 12 bytes (4 bytes for CAN ID + 8 bytes for data)
                    if (data.length == 12) {
                      // Extract the CAN ID from the received buffer
                      Uint8List canId_Bytes = Uint8List.fromList(
                          data.sublist(0, 4).toList().reversed.toList());
                      int canId = ByteData.view(canId_Bytes.buffer)
                          .getUint32(0, Endian.little);

                      // Extract the data from the received buffer
                      Uint8List messageData =
                          Uint8List.fromList(data.sublist(4, 12));

                      // Print the CAN ID and data
                      print('Received CAN ID: 0x${canId.toRadixString(16)}');
                      print('Received data: $messageData');
                    }
                  });
                });
              } else {
                print('Desired descriptor not found');
              }
            } else {
              print('Desired characteristic not found');
            }
          } else {
            print('Desired service not found');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: value.length,
              itemBuilder: (context, index) {
                final valueItem = value[index];
                String title = '';

                if (index == 0) {
                  title = 'RPM';
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

                return ListTile(
                  title: Text(title),
                  //subtitle: Text(valueItem.toString()),
                );
              },
            ),
            if (value.isEmpty) const Text('Still Loading Data...'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // button to navigate to the Debug Page
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SecondPage(
                  values:
                      value), // button press action for navigate to Second page - Debug page
            ),
          );
        },
        child: Icon(Icons.arrow_forward), // arrow icon towards second page.
      ),
    );
  }

  // default code - 2023/05/25
  // void _setupCharacteristicListener() {
  //   final desiredServiceUuid = Guid('000000FF-0000-1000-8000-00805F9B34FB');
  //   final desiredCharacteristicUuid =
  //       Guid('0000FF01-0000-1000-8000-00805F9B34FB');

  //   widget.device.state.listen((BluetoothDeviceState state) {
  //     if (state == BluetoothDeviceState.connected) {
  //       print('\n\n');
  //       print('Successfully connected');
  //       print('\n\n');
  //       print('Connected device name: ${widget.device.name}');
  //       print('\n\n');

  //       widget.device.discoverServices().then((services) async {
  //         final desiredService = services.firstWhereOrNull(
  //           (service) => service.uuid == desiredServiceUuid,
  //         );
  //         if (desiredService != null) {
  //           print('\n\n');
  //           print('Found desired service: ${desiredService.uuid}');
  //           print('\n\n');

  //           final desiredCharacteristic =
  //               desiredService.characteristics.firstWhereOrNull(
  //             (characteristic) =>
  //                 characteristic.uuid == desiredCharacteristicUuid,
  //           );
  //           if (desiredCharacteristic != null) {
  //             print('\n\n');
  //             print(
  //                 'Found desired characteristic: ${desiredCharacteristic.uuid}');
  //             print('\n\n');

  //             List<int> readValue = await desiredCharacteristic.read();
  //             setState(() {
  //               value = readValue;
  //             });
  //             print('\n\n');
  //             print('value is: $value');
  //             print('\n\n');
  //           } else {
  //             print('Desired characteristic not found');
  //           }
  //         } else {
  //           print('Desired service not found');
  //         }
  //       });
  //     }
  //   });
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       //title: Text(widget.device.name),
  //       title: Text('Home Page'),
  //     ),
  //     body: SingleChildScrollView(
  //       child: Column(
  //         children: <Widget>[
  //           if (value.isNotEmpty)
  //             ListView.builder(
  //               shrinkWrap: true,
  //               itemCount: value.length,
  //               itemBuilder: (context, index) {
  //                 final valueItem = value[index];
  //                 return ListTile(
  //                   title: Text('Value $index'),
  //                   subtitle: Text(valueItem.toString()),
  //                 );
  //               },
  //             ),
  //           if (value.isEmpty) const Text('No data available'),
  //         ],
  //       ),
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       // button to navigate to the Debug Page
  //       onPressed: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => SecondPage(
  //                 values:
  //                     values), // button press action for navigate to Second page - Debug page
  //           ),
  //         );
  //       },
  //       child: Icon(Icons.arrow_forward), // arrow icon towards second page.
  //     ),
  //   );
  // }
}

// class DeviceScreen extends StatefulWidget {
//   const DeviceScreen({Key? key, required this.device}) : super(key: key);

//   final BluetoothDevice device;

//   @override
//   _DeviceScreenState createState() => _DeviceScreenState();
// }

// class _DeviceScreenState extends State<DeviceScreen> {
//   final List<int> values = [];

//   @override
//   void initState() {
//     super.initState();
//     _setupCharacteristicListener();
//   }

//   void _setupCharacteristicListener() {
//     final desiredServiceUuid = Guid('0000ff01-0000-1000-8000-00805f9b34fb');
//     final desiredCharacteristicUuid =
//         Guid('0000ff01-0000-1000-8000-00805f9b34fb');

//     widget.device.state.listen((BluetoothDeviceState state) {
//       if (state == BluetoothDeviceState.connected) {
//         widget.device.discoverServices().then((services) {
//           final desiredService = services.firstWhereOrNull(
//             (service) => service.uuid == desiredServiceUuid,
//           );
//           if (desiredService != null) {
//             final desiredCharacteristic =
//                 desiredService.characteristics.firstWhereOrNull(
//               (characteristic) =>
//                   characteristic.uuid == desiredCharacteristicUuid,
//             );
//             if (desiredCharacteristic != null) {
//               desiredCharacteristic.setNotifyValue(true);
//               desiredCharacteristic.value.listen((value) {
//                 setState(() {
//                   values.add(value);
//                 });
//               });
//             }
//           }
//         });
//       }
//     });
//   }

// void _setupCharacteristicListener() {
//   final desiredServiceUuid = Guid('0000ff01-0000-1000-8000-000000000000');
//   final desiredCharacteristicUuid =
//       Guid('0000ff01-0000-1000-8000-000000000000');

//   widget.device.state.listen((BluetoothDeviceState state) {
//     if (state == BluetoothDeviceState.connected) {
//       widget.device.discoverServices().then((services) {
//         final desiredService = services.firstWhereOrNull(
//           (service) => service.uuid == desiredServiceUuid,
//         );
//         if (desiredService != null) {
//           final desiredCharacteristic =
//               desiredService.characteristics.firstWhereOrNull(
//             (characteristic) =>
//                 characteristic.uuid == desiredCharacteristicUuid,
//           );
//           if (desiredCharacteristic != null) {
//             desiredCharacteristic.setNotifyValue(true);
//             desiredCharacteristic.value.listen((value) {
//               setState(() {
//                 values.clear();
//                 values.addAll(value);
//               });
//             });
//           }
//         }
//       });
//     }
//   });
// }

// class DeviceScreen extends StatefulWidget {
//   final BluetoothDevice device;

//   const DeviceScreen({Key? key, required this.device}) : super(key: key);

//   @override
//   _DeviceScreenState createState() => _DeviceScreenState();
// }

// class _DeviceScreenState extends State<DeviceScreen> {
//   List<int> values = [];

//   @override
//   void initState() {
//     super.initState();
//     _readValues();
//   }

//   Future<void> _readValues() async {
//     try {
//       final services = await widget.device.discoverServices();
//       final desiredService = services.firstWhere(
//         (service) =>
//             service.uuid.toString() == '0000ff01-0000-1000-8000-00805f9b34fb',
//         //orElse: () => null,
//       );

//       if (desiredService != null) {
//         final characteristics = await desiredService.characteristics.toList();
//         final desiredCharacteristic = characteristics.firstWhere(
//           (characteristic) =>
//               characteristic.uuid.toString() ==
//               '0000ff01-0000-1000-8000-00805f9b34fb',
//           //orElse: () => null,
//         );

//         if (desiredCharacteristic != null) {
//           final value = await desiredCharacteristic.read();
//           setState(() {
//             values = value;
//           });
//         }
//       }
//     } catch (e) {
//       print('Error reading values: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Device Screen'),
//       ),
//       body: Center(
//         child: ListView.builder(
//           itemCount: values.length,
//           itemBuilder: (context, index) {
//             final value = values[index];
//             return ListTile(
//               title: Text('Value $index'),
//               subtitle: Text(value.toString()),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

//testing - 05/25
// class _DeviceScreenState extends State<DeviceScreen> {
//   final List<Map<String, dynamic>> values = [
//     {'title': 'Speed (km/h)', 'value': 60.0},
//     {'title': 'Pack Voltage (V)', 'value': 48.0},
//     {'title': 'Highest Cell (V)', 'value': 4.2},
//     {'title': 'Lowest Cell (V)', 'value': 3.8},
//     {'title': 'DC Current (A)', 'value': 10.0},
//     {'title': 'Pack Temperature (°C)', 'value': 25.0},
//     {'title': 'Battery Charge (%)', 'value': 25},
//   ]; // the values list

//   List<int> value = [];
//   String receivedMessage = '';
//   bool isReading = false; // Flag to track read operation

//   // ... rest of your code ...

//   void _setupCharacteristicListener() {
//     final desiredServiceUuid = Guid('000000FF-0000-1000-8000-00805F9B34FB');
//     final desiredCharacteristicUuid =
//         Guid('0000FF01-0000-1000-8000-00805F9B34FB');

//     widget.device.state.listen((BluetoothDeviceState state) {
//       if (state == BluetoothDeviceState.connected) {
//         widget.device.discoverServices().then((services) {
//           final desiredService = services.firstWhereOrNull(
//             (service) => service.uuid == desiredServiceUuid,
//           );
//           if (desiredService != null) {
//             final desiredCharacteristic =
//                 desiredService.characteristics.firstWhereOrNull(
//               (characteristic) =>
//                   characteristic.uuid == desiredCharacteristicUuid,
//             );
//             if (desiredCharacteristic != null) {
//               desiredCharacteristic.setNotifyValue(true);

//               // Listen to notifications
//               desiredCharacteristic.value.listen((data) {
//                 setState(() {
//                   value = data; // Update the value list with received data
//                 });
//               });
//             }
//           }
//         });
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _setupCharacteristicListener();
//   }

//   // ... rest of your code ...
// }
