import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_model.dart';
import '../providers/database_provider.dart';
import '../services/notification_service.dart';
import '../utils/helpers.dart';

class ReminderDetailScreen extends ConsumerStatefulWidget {
  final Reminder? reminder;

  const ReminderDetailScreen({
    super.key,
    this.reminder,
  });

  @override
  ConsumerState<ReminderDetailScreen> createState() => 
      _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends ConsumerState<ReminderDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDateTime;
  late RepeatType _repeatType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.reminder?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.reminder?.description ?? '',
    );
    _selectedDateTime = widget.reminder?.dateTime ?? 
        DateTime.now().add(const Duration(hours: 1));
    _repeatType = widget.reminder?.repeatType ?? RepeatType.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveReminder() async {
    if (_titleController.text.trim().isEmpty) {
      Helpers.showSnackBar(
        context,
        'Başlık boş olamaz',
        isError: true,
      );
      return;
    }

    if (_selectedDateTime.isBefore(DateTime.now())) {
      Helpers.showSnackBar(
        context,
        'Geçmiş bir tarih seçilemez',
        isError: true,
      );
      return;
    }

    // Bildirim izni kontrolü
    final hasPermission = await NotificationService.checkPermission();
    if (!hasPermission) {
      final granted = await NotificationService.requestPermission();
      if (!granted && mounted) {
        final shouldContinue = await Helpers.showConfirmDialog(
          context,
          title: 'Bildirim İzni',
          content: 'Hatırlatmalar için bildirim izni gereklidir. İzin vermeden devam etmek istiyor musunuz?',
          confirmText: 'Devam Et',
        );
        if (!shouldContinue) return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = await ref.read(reminderRepositoryProvider.future);
      
      final reminder = widget.reminder ?? Reminder(
        title: '',
        dateTime: DateTime.now(),
      );
      reminder.title = _titleController.text.trim();
      reminder.description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      reminder.dateTime = _selectedDateTime;
      reminder.repeatType = _repeatType;

      final id = await repo.saveReminder(reminder);
      
      // Bildirim planla
      if (!reminder.isCompleted) {
        reminder.id = id;
        await NotificationService.scheduleReminder(reminder);
      }

      ref.invalidate(remindersProvider);
      ref.invalidate(todaysRemindersProvider);

      if (mounted) {
        Navigator.of(context).pop();
        Helpers.showSnackBar(
          context,
          widget.reminder == null 
              ? 'Hatırlatma oluşturuldu' 
              : 'Hatırlatma güncellendi',
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Kaydetme hatası: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteReminder() async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Hatırlatmayı Sil',
      content: 'Bu hatırlatma kalıcı olarak silinecek. Emin misin?',
      isDangerous: true,
    );

    if (confirmed && widget.reminder != null) {
      final repo = await ref.read(reminderRepositoryProvider.future);
      await repo.deleteReminder(widget.reminder!.id);
      await NotificationService.cancelNotification(widget.reminder!.id);
      ref.invalidate(remindersProvider);
      ref.invalidate(todaysRemindersProvider);
      
      if (mounted) {
        Navigator.of(context).pop();
        Helpers.showSnackBar(context, 'Hatırlatma silindi');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.reminder != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Hatırlatmayı Düzenle' : 'Yeni Hatırlatma'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteReminder,
              tooltip: 'Sil',
            ),
          TextButton.icon(
            onPressed: _isSaving ? null : _saveReminder,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isSaving ? 'Kaydediliyor...' : 'Kaydet'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Başlık',
                prefixIcon: Icon(Icons.title),
              ),
              style: theme.textTheme.titleLarge,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Açıklama (opsiyonel)',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              style: theme.textTheme.bodyLarge,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 24),
            
            // Date & Time
            Text(
              'Tarih ve Saat',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                ),
                title: Text(Helpers.formatDate(_selectedDateTime)),
                subtitle: Text(Helpers.formatTime(_selectedDateTime)),
                trailing: const Icon(Icons.edit),
                onTap: _selectDateTime,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Repeat
            Text(
              'Tekrar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  RadioListTile<RepeatType>(
                    title: const Text('Tekrar Yok'),
                    value: RepeatType.none,
                    groupValue: _repeatType,
                    onChanged: (value) {
                      setState(() {
                        _repeatType = value!;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<RepeatType>(
                    title: const Text('Her Gün'),
                    value: RepeatType.daily,
                    groupValue: _repeatType,
                    onChanged: (value) {
                      setState(() {
                        _repeatType = value!;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<RepeatType>(
                    title: const Text('Her Hafta'),
                    value: RepeatType.weekly,
                    groupValue: _repeatType,
                    onChanged: (value) {
                      setState(() {
                        _repeatType = value!;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<RepeatType>(
                    title: const Text('Her Ay'),
                    value: RepeatType.monthly,
                    groupValue: _repeatType,
                    onChanged: (value) {
                      setState(() {
                        _repeatType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info
            if (isEditing) ...[
              Card(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Bilgi',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Oluşturulma: ${Helpers.formatDateTime(widget.reminder!.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (widget.reminder!.isCompleted)
                        Text(
                          'Durum: Tamamlandı',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
