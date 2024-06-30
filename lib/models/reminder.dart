class Reminder {
  int? id;
  String title;
  DateTime dateTime;

  Reminder({this.id, required this.title, required this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  static Reminder fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}
