import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/note_model.dart';
import '../models/reminder_model.dart';
import '../services/database_service.dart';

// Database Provider
final databaseProvider = FutureProvider<Isar>((ref) async {
  return await DatabaseService.isar;
});

// Note Repository Provider
final noteRepositoryProvider = FutureProvider<NoteRepository>((ref) async {
  final isar = await ref.watch(databaseProvider.future);
  return NoteRepository(isar);
});

// Reminder Repository Provider
final reminderRepositoryProvider = FutureProvider<ReminderRepository>((ref) async {
  final isar = await ref.watch(databaseProvider.future);
  return ReminderRepository(isar);
});

// Notes Provider
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final repo = await ref.watch(noteRepositoryProvider.future);
  return repo.getAllNotes();
});

// Recent Notes Provider
final recentNotesProvider = FutureProvider<List<Note>>((ref) async {
  final repo = await ref.watch(noteRepositoryProvider.future);
  return repo.getRecentNotes(limit: 5);
});

// Note Search Provider
final noteSearchProvider = FutureProvider.family<List<Note>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final repo = await ref.watch(noteRepositoryProvider.future);
  return repo.searchNotes(query);
});

// All Tags Provider
final allTagsProvider = FutureProvider<List<String>>((ref) async {
  final repo = await ref.watch(noteRepositoryProvider.future);
  return repo.getAllTags();
});

// Reminders Provider
final remindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final repo = await ref.watch(reminderRepositoryProvider.future);
  return repo.getAllReminders();
});

// Today's Reminders Provider
final todaysRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final repo = await ref.watch(reminderRepositoryProvider.future);
  return repo.getTodaysReminders();
});

// Upcoming Reminders Provider
final upcomingRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final repo = await ref.watch(reminderRepositoryProvider.future);
  return repo.getUpcomingReminders();
});

// Overdue Reminders Provider
final overdueRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final repo = await ref.watch(reminderRepositoryProvider.future);
  return repo.getOverdueReminders();
});

// Note by ID Provider
final noteByIdProvider = FutureProvider.family<Note?, int>((ref, id) async {
  final repo = await ref.watch(noteRepositoryProvider.future);
  return repo.getNoteById(id);
});

// Reminder by ID Provider
final reminderByIdProvider = FutureProvider.family<Reminder?, int>((ref, id) async {
  final repo = await ref.watch(reminderRepositoryProvider.future);
  return repo.getReminderById(id);
});
