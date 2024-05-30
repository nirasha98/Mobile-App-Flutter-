//A Model
//use to get user inputs in third page.
//for Shared preferences.

class UserInput {
  final String title;
  final String value;
  final String type;
  final String CanId;
  final int packet;
  final String? byteindex;
  final String? bitindex;
  final String? highbyteindex;
  final String? lowbyteindex;
  final String? datatype;

  UserInput(
      {required this.title,
      required this.value,
      required this.type,
      required this.CanId,
      required this.packet,
      required this.byteindex,
      required this.bitindex,
      this.highbyteindex,
      this.lowbyteindex,
      this.datatype});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'value': value,
      'type': type,
      'canId': CanId,
      'packet': packet,
      'byteindex': byteindex,
      'bitindex': bitindex,
      'highbyteindex': highbyteindex,
      'lowbyteindex': lowbyteindex,
      'datatype': datatype,
    };
  }

  factory UserInput.fromMap(Map<String, dynamic> map) {
    return UserInput(
        title: map['title'],
        value: map['value'],
        type: map['type'],
        CanId: map['canId'],
        packet: map['packet'],
        byteindex: map['byteindex'],
        bitindex: map['bitindex'],
        highbyteindex: map['highbyteindex'],
        lowbyteindex: map['lowbyteindex'],
        datatype: map['datatype']);
  }
}
