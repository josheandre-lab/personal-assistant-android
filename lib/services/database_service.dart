import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';
import '../models/reminder_model.dart';

class DatabaseService {
  static Isar? _isar;
  
  static Future<Isar> get isar async {
    if (_isar != null) return _isar!;
    _isar = await _initIsar();
    return _isar!;
  }
  
  static Future<Isar> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    
    return await Isar.open(
      [NoteSchema, ReminderSchema],
      directory: dir.path,
    );
  }
  
  static Future<void> close() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
    }
  }
}

class NoteRepository {
  final Isar _isar;
  
  NoteRepository(this._isar);
  
  Future<List<Note>> getAllNotes() async {
    return await _isar.notes
        .where()
        .sortByIsPinnedDesc()
        .thenByUpdatedAtDesc()
        .findAll();
  }
  
  Future<List<Note>> searchNotes(String query) async {
    final lowerQuery = query.toLowerCase();
    
    return await _isar.notes
        .filter()
        .anyOf(
          [lowerQuery],
          (q, element) => q
            .titleContains(element, caseSensitive: false)
            .or()
            .contentContains(element, caseSensitive: false)
            .or()
            .tagsElementContains(element, caseSensitive: false),
        )
        .sortByIsPinnedDesc()
        .thenByUpdatedAtDesc()
        .findAll();
  }
  
  Future<List<Note>> getRecentNotes({int limit = 5}) async {
    return await _isar.notes
        .where()
        .sortByUpdatedAtDesc()
        .limit(limit)
        .findAll();
  }
  
  Future<List<Note>> getNotesByTag(String tag) async {
    return await _isar.notes
        .filter()
        .tagsElementContains(tag, caseSensitive: false)
        .sortByUpdatedAtDesc()
        .findAll();
  }
  
  Future<List<String>> getAllTags() async {
    final notes = await _isar.notes.where().findAll();
    final tags = <String>{};
    for (final note in notes) {
      tags.addAll(note.tags);
    }
    return tags.toList()..sort();
  }
  
  Future<Note?> getNoteById(int id) async {
    return await _isar.notes.get(id);
  }
  
  Future<int> saveNote(Note note) async {
    note.updatedAt = DateTime.now();
    return await _isar.writeTxn(() async {
      return await _isar.notes.put(note);
    });
  }
  
  Future<void> deleteNote(int id) async {
    await _isar.writeTxn(() async {
      await _isar.notes.delete(id);
    });
  }
  
  Future<void> togglePin(int id) async {
    final note = await _isar.notes.get(id);
    if (note != null) {
      note.isPinned = !note.isPinned;
      await saveNote(note);
    }
  }
  
  Future<void> updateSummary(int id, String summary) async {
    final note = await _isar.notes.get(id);
    if (note != null) {
      note.summary = summary;
      await saveNote(note);
    }
  }
}

class ReminderRepository {
  final Isar _isar;
  
  ReminderRepository(this._isar);
  
  Future<List<Reminder>> getAllReminders() async {
    return await _isar.reminders
        .where()
        .sortByDateTimeAsc()
        .findAll();
  }
  
  Future<List<Reminder>> getUpcomingReminders() async {
    final now = DateTime.now();
    return await _isar.reminders
        .filter()
        .isCompletedEqualTo(false)
        .and()
        .dateTimeGreaterThan(now)
        .sortByDateTimeAsc()
        .findAll();
  }
  
  Future<List<Reminder>> getTodaysReminders() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return await _isar.reminders
        .filter()
        .isCompletedEqualTo(false)
        .and()
        .dateTimeBetween(startOfDay, endOfDay)
        .sortByDateTimeAsc()
        .findAll();
  }
  
  Future<List<Reminder>> getOverdueReminders() async {
    final now = DateTime.now();
    return await _isar.reminders
        .filter()
        .isCompletedEqualTo(false)
        .and()
        .dateTimeLessThan(now)
        .sortByDateTimeAsc()
        .findAll();
  }
  
  Future<Reminder?> getReminderById(int id) async {
    return await _isar.reminders.get(id);
  }
  
  Future<int> saveReminder(Reminder reminder) async {
    return await _isar.writeTxn(() async {
      return await _isar.reminders.put(reminder);
    });
  }
  
  Future<void> deleteReminder(int id) async {
    await _isar.writeTxn(() async {
      await _isar.reminders.delete(id);
    });
  }
  
  Future<void> toggleComplete(int id) async {
    final reminder = await _isar.reminders.get(id);
    if (reminder != null) {
      reminder.isCompleted = !reminder.isCompleted;
      await saveReminder(reminder);
    }
  }
  
  Future<void> snoozeReminder(int id, Duration duration) async {
    final reminder = await _isar.reminders.get(id);
    if (reminder != null) {
      reminder.isSnoozed = true;
      reminder.snoozeUntil = DateTime.now().add(duration);
      await saveReminder(reminder);
    }
  }
  
  Future<void> cancelSnooze(int id) async {
    final reminder = await _isar.reminders.get(id);
    if (reminder != null) {
      reminder.isSnoozed = false;
      reminder.snoozeUntil = null;
      await saveReminder(reminder);
    }
  }
  
  Future<List<Reminder>> getPendingNotifications() async {
    final now = DateTime.now();
    return await _isar.reminders
        .filter()
        .isCompletedEqualTo(false)
        .and()
        .group((q) => q
          .isSnoozedEqualTo(false)
          .or()
          .group((q2) => q2
            .isSnoozedEqualTo(true)
            .and()
            .snoozeUntilLessThan(now)
          )
        )
        .sortByDateTimeAsc()
        .findAll();
  }
}
