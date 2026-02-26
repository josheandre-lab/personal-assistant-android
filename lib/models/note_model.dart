import 'package:isar/isar.dart';

part 'note_model.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;
  
  late String title;
  late String content;
  
  @Index()
  DateTime createdAt = DateTime.now();
  
  @Index()
  DateTime updatedAt = DateTime.now();
  
  List<String> tags = [];
  
  bool isPinned = false;
  
  String? summary;
  
  Note({
    required this.title,
    required this.content,
    this.tags = const [],
    this.isPinned = false,
    this.summary,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'isPinned': isPinned,
      'summary': summary,
    };
  }
  
  factory Note.fromJson(Map<String, dynamic> json) {
    final note = Note(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      isPinned: json['isPinned'] ?? false,
      summary: json['summary'],
    );
    note.id = json['id'] ?? Isar.autoIncrement;
    note.createdAt = DateTime.parse(json['createdAt']);
    note.updatedAt = DateTime.parse(json['updatedAt']);
    return note;
  }
}
