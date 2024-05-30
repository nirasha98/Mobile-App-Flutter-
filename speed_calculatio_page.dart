import 'package:flutter/material.dart';

class SpeedPage extends StatefulWidget {
  final int initialValue;
  final int index;
  final String TiTle;

  SpeedPage({
    Key? key,
    required this.initialValue,
    required this.index,
    required this.TiTle,
  }) : super(key: key);

  @override
  _SpeedPageState createState() => _SpeedPageState();
}

class _SpeedPageState extends State<SpeedPage> {
  final _wheelRadiusController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _wheelRadiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speed'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            height:
                MediaQuery.of(context).size.height, // Added height constraint
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _wheelRadiusController,
                  decoration: InputDecoration(
                    hintText: 'eg: 0.2 m',
                    labelText: 'Wheel Radius',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the wheel radius';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Flexible(
                  // Replaced Expanded with Flexible
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final double wheelRadius =
                            double.parse(_wheelRadiusController.text);
                        final double wheelDiameter = wheelRadius * 2;
                        final double wheelDiameterInCm = wheelDiameter * 100;

                        final double speedValue =
                            wheelDiameterInCm * 0.001885 * widget.initialValue;
                        final int convertedValue = speedValue.toInt();
                        //setState(() {
                        //widget.TiTle = 'Speed';
                        //});

                        final String updatedTitle = 'Speed';

                        Navigator.pop(context, {
                          'updatedValue': convertedValue,
                          'updatedTitle': updatedTitle,
                        });
                      }
                    },
                    child: Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
