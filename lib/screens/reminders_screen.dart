import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_model.dart';
import '../providers/database_provider.dart';
import '../services/notification_service.dart';
import '../utils/helpers.dart';
import 'reminder_detail_screen.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: reminders.when(
        data: (reminderList) {
          if (reminderList.isEmpty) {
            return _EmptyState();
          }

          // Gruplandır
          final upcoming = reminderList
              .where((r) => !r.isCompleted && r.dateTime.isAfter(DateTime.now()))
              .toList();
          final overdue = reminderList
              .where((r) => !r.isCompleted && r.dateTime.isBefore(DateTime.now()))
              .toList();
          final completed = reminderList.where((r) => r.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (overdue.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Gecikmiş',
                  count: overdue.length,
                  color: theme.colorScheme.error,
                ),
                ...overdue.map((r) => _ReminderCard(
                  reminder: r,
                  onToggle: () => _toggleComplete(ref, r),
                  onEdit: () => _editReminder(context, r),
                  onDelete: () => _deleteReminder(context, ref, r),
                  onSnooze: () => _snoozeReminder(context, ref, r),
                )),
                const SizedBox(height: 16),
              ],
              if (upcoming.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Yaklaşan',
                  count: upcoming.length,
                  color: theme.colorScheme.primary,
                ),
                ...upcoming.map((r) => _ReminderCard(
                  reminder: r,
                  onToggle: () => _toggleComplete(ref, r),
                  onEdit: () => _editReminder(context, r),
                  onDelete: () => _deleteReminder(context, ref, r),
                  onSnooze: () => _snoozeReminder(context, ref, r),
                )),
                const SizedBox(height: 16),
              ],
              if (completed.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Tamamlanmış',
                  count: completed.length,
                  color: theme.colorScheme.outline,
                ),
                ...completed.map((r) => _ReminderCard(
                  reminder: r,
                  onToggle: () => _toggleComplete(ref, r),
                  onEdit: () => _editReminder(context, r),
                  onDelete: () => _deleteReminder(context, ref, r),
                  onSnooze: null,
                )),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Hatırlatmalar yüklenemedi',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ReminderDetailScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Hatırlatma Ekle'),
      ),
    );
  }

  Future<void> _toggleComplete(WidgetRef ref, Reminder reminder) async {
    final repo = await ref.read(reminderRepositoryProvider.future);
    await repo.toggleComplete(reminder.id);
    ref.invalidate(remindersProvider);
    ref.invalidate(todaysRemindersProvider);
    
    if (reminder.isCompleted) {
      await NotificationService.cancelNotification(reminder.id);
    } else {
      await NotificationService.scheduleReminder(reminder);
    }
  }

  void _editReminder(BuildContext context, Reminder reminder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReminderDetailScreen(reminder: reminder),
      ),
    );
  }

  Future<void> _deleteReminder(
    BuildContext context,
    WidgetRef ref,
    Reminder reminder,
  ) async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Hatırlatmayı Sil',
      content: '"${reminder.title}" silinecek. Emin misin?',
      isDangerous: true,
    );

    if (confirmed) {
      final repo = await ref.read(reminderRepositoryProvider.future);
      await repo.deleteReminder(reminder.id);
      await NotificationService.cancelNotification(reminder.id);
      ref.invalidate(remindersProvider);
      ref.invalidate(todaysRemindersProvider);
      
      if (context.mounted) {
        Helpers.showSnackBar(context, 'Hatırlatma silindi');
      }
    }
  }

  Future<void> _snoozeReminder(
    BuildContext context,
    WidgetRef ref,
    Reminder reminder,
  ) async {
    final result = await showDialog<Duration>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ertele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('10 dakika'),
              onTap: () => Navigator.pop(context, const Duration(minutes: 10)),
            ),
            ListTile(
              title: const Text('1 saat'),
              onTap: () => Navigator.pop(context, const Duration(hours: 1)),
            ),
            ListTile(
              title: const Text('1 gün'),
              onTap: () => Navigator.pop(context, const Duration(days: 1)),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final repo = await ref.read(reminderRepositoryProvider.future);
      await repo.snoozeReminder(reminder.id, result);
      ref.invalidate(remindersProvider);
      ref.invalidate(todaysRemindersProvider);
      
      if (context.mounted) {
        Helpers.showSnackBar(
          context,
          '${result.inMinutes} dakika ertelendi',
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text('$count'),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSnooze;

  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = reminder.isOverdue;

    return Dismissible(
      key: Key('reminder_${reminder.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete,
          color: theme.colorScheme.onError,
        ),
      ),
      confirmDismiss: (direction) async {
        return await Helpers.showConfirmDialog(
          context,
          title: 'Hatırlatmayı Sil',
          content: '"${reminder.title}" silinecek. Emin misin?',
          isDangerous: true,
        );
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Checkbox(
            value: reminder.isCompleted,
            onChanged: (_) => onToggle(),
          ),
          title: Text(
            reminder.title,
            style: TextStyle(
              decoration: reminder.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
              color: reminder.isCompleted
                  ? theme.colorScheme.outline
                  : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reminder.description != null)
                Text(
                  reminder.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: isOverdue
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Helpers.formatDateTime(reminder.dateTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isOverdue
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isOverdue ? FontWeight.bold : null,
                    ),
                  ),
                  if (reminder.repeatType != RepeatType.none) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.repeat,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Helpers.getRepeatTypeText(reminder.repeatType.name),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit();
                  break;
                case 'snooze':
                  onSnooze?.call();
                  break;
                case 'delete':
                  onDelete();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined),
                    const SizedBox(width: 12),
                    const Text('Düzenle'),
                  ],
                ),
              ),
              if (onSnooze != null)
                PopupMenuItem(
                  value: 'snooze',
                  child: Row(
                    children: [
                      const Icon(Icons.snooze_outlined),
                      const SizedBox(width: 12),
                      const Text('Ertele'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sil',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: onEdit,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alarm_off_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz hatırlatma eklememişsin',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bir hatırlatma eklemek için + butonuna tıkla',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
