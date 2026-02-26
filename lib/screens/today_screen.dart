import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../services/summary_service.dart';
import '../utils/helpers.dart';
import 'note_detail_screen.dart';
import 'reminder_detail_screen.dart';
import 'note_edit_screen.dart';
import 'briefing_screen.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaysReminders = ref.watch(todaysRemindersProvider);
    final recentNotes = ref.watch(recentNotesProvider);
    final theme = Theme.of(context);
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(todaysRemindersProvider);
        ref.invalidate(recentNotesProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.wb_sunny_outlined,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Helpers.getGreeting(),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bugün neler yapacaksın?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BriefingScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.summarize_outlined),
                      label: const Text('Günlük Brifing Al'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Add
            Text(
              'Hızlı Ekle',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAddCard(
                    icon: Icons.note_add_outlined,
                    label: 'Yeni Not',
                    color: theme.colorScheme.primaryContainer,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NoteEditScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAddCard(
                    icon: Icons.add_alarm_outlined,
                    label: 'Hatırlatma',
                    color: theme.colorScheme.secondaryContainer,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReminderDetailScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Today's Reminders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bugünün Hatırlatmaları',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to reminders tab
                  },
                  child: const Text('Tümü'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            todaysReminders.when(
              data: (reminders) {
                if (reminders.isEmpty) {
                  return _EmptyState(
                    icon: Icons.check_circle_outline,
                    message: 'Bugün için hatırlatman yok',
                  );
                }
                return Column(
                  children: reminders.map((reminder) {
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.alarm,
                          color: reminder.isOverdue
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                        title: Text(reminder.title),
                        subtitle: Text(
                          reminder.description ?? 
                          Helpers.formatTime(reminder.dateTime),
                        ),
                        trailing: Checkbox(
                          value: reminder.isCompleted,
                          onChanged: (value) async {
                            final repo = await ref.read(
                              reminderRepositoryProvider.future,
                            );
                            await repo.toggleComplete(reminder.id);
                            ref.invalidate(todaysRemindersProvider);
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReminderDetailScreen(
                                reminder: reminder,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const _EmptyState(
                icon: Icons.error_outline,
                message: 'Hatırlatmalar yüklenemedi',
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Notes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son Notlar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to notes tab
                  },
                  child: const Text('Tümü'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            recentNotes.when(
              data: (notes) {
                if (notes.isEmpty) {
                  return _EmptyState(
                    icon: Icons.note_outlined,
                    message: 'Henüz not eklememişsin',
                  );
                }
                return Column(
                  children: notes.map((note) {
                    return Card(
                      child: ListTile(
                        leading: note.isPinned
                            ? Icon(
                                Icons.push_pin,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        title: Text(
                          note.title.isEmpty ? 'Başlıksız Not' : note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          Helpers.formatRelativeTime(note.updatedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NoteDetailScreen(note: note),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const _EmptyState(
                icon: Icons.error_outline,
                message: 'Notlar yüklenemedi',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
