//A Model
//use to get user inputs in third page.
//for Shared preferences.

class UserInputValue {
  final String title;
  final String value;
  final String type;
  final String CanId;
  final int packet;
  final String? highbyteindex;
  final String lowbyteindex;

  UserInputValue(
      {required this.title,
      required this.value,
      required this.type,
      required this.CanId,
      required this.packet,
      this.highbyteindex,
      required this.lowbyteindex});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'value': value,
      'type': type,
      'canId': CanId,
      'packet': packet,
      'byteindex': highbyteindex,
      'bitindex': lowbyteindex,
    };
  }

  factory UserInputValue.fromMap(Map<String, dynamic> map) {
    return UserInputValue(
        title: map['title'],
        value: map['value'],
        type: map['type'],
        CanId: map['canId'],
        packet: map['packet'],
        highbyteindex: map['highbyteindex'],
        lowbyteindex: map['lowbyteindex']);
  }
}
