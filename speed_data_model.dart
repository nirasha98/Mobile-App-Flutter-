//A Model
//use to get user inputs in third page.
//for Shared preferences.

class Speed_UserInput {
  final String title;
  final int value;

  Speed_UserInput({
    required this.title,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'value': value,
    };
  }

  factory Speed_UserInput.fromMap(Map<String, dynamic> map) {
    return Speed_UserInput(
      title: map['title'],
      value: map['value'],
    );
  }
}
