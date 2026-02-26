import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note_model.dart';
import '../models/reminder_model.dart';
import 'database_service.dart';

class ExportService {
  static Future<String> exportAllData() async {
    final isar = await DatabaseService.isar;
    final noteRepo = NoteRepository(isar);
    final reminderRepo = ReminderRepository(isar);
    
    final notes = await noteRepo.getAllNotes();
    final reminders = await reminderRepo.getAllReminders();
    
    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'notes': notes.map((n) => n.toJson()).toList(),
      'reminders': reminders.map((r) => r.toJson()).toList(),
    };
    
    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'personal_assistant_backup_${
      DateTime.now().millisecondsSinceEpoch
    }.json';
    final filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsString(jsonString);
    
    return filePath;
  }
  
  static Future<void> shareExportedData(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Kişisel Asistan yedek dosyası',
    );
  }
  
  static Future<Map<String, dynamic>?> importData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return data;
    } catch (e) {
      return null;
    }
  }
  
  static Future<List<Note>> importNotes(List<dynamic> notesJson) async {
    final notes = <Note>[];
    for (final json in notesJson) {
      try {
        notes.add(Note.fromJson(json as Map<String, dynamic>));
      } catch (e) {
        // Hatalı notları atla
      }
    }
    return notes;
  }
  
  static Future<List<Reminder>> importReminders(List<dynamic> remindersJson) async {
    final reminders = <Reminder>[];
    for (final json in remindersJson) {
      try {
        reminders.add(Reminder.fromJson(json as Map<String, dynamic>));
      } catch (e) {
        // Hatalı hatırlatmaları atla
      }
    }
    return reminders;
  }
}
