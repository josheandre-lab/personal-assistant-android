import 'package:isar/isar.dart';

part 'reminder_model.g.dart';

enum RepeatType {
  none,
  daily,
  weekly,
  monthly,
}

@collection
class Reminder {
  Id id = Isar.autoIncrement;
  
  late String title;
  String? description;
  
  @Index()
  DateTime dateTime;
  
  @enumerated
  RepeatType repeatType = RepeatType.none;
  
  bool isCompleted = false;
  
  @Index()
  bool isSnoozed = false;
  
  DateTime? snoozeUntil;
  
  DateTime createdAt = DateTime.now();
  
  Reminder({
    required this.title,
    this.description,
    required this.dateTime,
    this.repeatType = RepeatType.none,
    this.isCompleted = false,
  });
  
  bool get isOverdue => !isCompleted && dateTime.isBefore(DateTime.now());
  
  bool get shouldNotify {
    if (isCompleted) return false;
    if (isSnoozed && snoozeUntil != null) {
      return DateTime.now().isAfter(snoozeUntil!);
    }
    return true;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'repeatType': repeatType.name,
      'isCompleted': isCompleted,
      'isSnoozed': isSnoozed,
      'snoozeUntil': snoozeUntil?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory Reminder.fromJson(Map<String, dynamic> json) {
    final reminder = Reminder(
      title: json['title'] ?? '',
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      repeatType: RepeatType.values.firstWhere(
        (e) => e.name == json['repeatType'],
        orElse: () => RepeatType.none,
      ),
      isCompleted: json['isCompleted'] ?? false,
    );
    reminder.id = json['id'] ?? Isar.autoIncrement;
    reminder.isSnoozed = json['isSnoozed'] ?? false;
    reminder.snoozeUntil = json['snoozeUntil'] != null 
        ? DateTime.parse(json['snoozeUntil']) 
        : null;
    reminder.createdAt = DateTime.parse(json['createdAt']);
    return reminder;
  }
  
  Reminder copy() {
    final copy = Reminder(
      title: title,
      description: description,
      dateTime: dateTime,
      repeatType: repeatType,
      isCompleted: isCompleted,
    );
    copy.id = id;
    copy.isSnoozed = isSnoozed;
    copy.snoozeUntil = snoozeUntil;
    copy.createdAt = createdAt;
    return copy;
  }
}
