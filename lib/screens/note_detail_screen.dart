import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../services/summary_service.dart';
import '../utils/helpers.dart';
import 'note_edit_screen.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final Note note;

  const NoteDetailScreen({
    super.key,
    required this.note,
  });

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  bool _isSummarizing = false;

  Future<void> _summarizeNote() async {
    setState(() {
      _isSummarizing = true;
    });

    try {
      final useAi = ref.read(useAiSummarizationProvider);
      final summary = await SummaryService.summarize(
        widget.note.content,
        useAi: useAi,
      );

      final repo = await ref.read(noteRepositoryProvider.future);
      await repo.updateSummary(widget.note.id, summary);

      if (mounted) {
        Helpers.showSnackBar(context, 'Not özeti oluşturuldu');
        ref.invalidate(noteByIdProvider(widget.note.id));
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Özet oluşturulamadı: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSummarizing = false;
        });
      }
    }
  }

  Future<void> _togglePin() async {
    final repo = await ref.read(noteRepositoryProvider.future);
    await repo.togglePin(widget.note.id);
    ref.invalidate(notesProvider);
    ref.invalidate(noteByIdProvider(widget.note.id));
    
    if (mounted) {
      Helpers.showSnackBar(
        context,
        widget.note.isPinned ? 'Notun sabitlemesi kaldırıldı' : 'Not sabitlendi',
      );
    }
  }

  Future<void> _deleteNote() async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Notu Sil',
      content: 'Bu not kalıcı olarak silinecek. Emin misin?',
      isDangerous: true,
    );

    if (confirmed && mounted) {
      final repo = await ref.read(noteRepositoryProvider.future);
      await repo.deleteNote(widget.note.id);
      ref.invalidate(notesProvider);
      
      if (mounted) {
        Navigator.of(context).pop();
        Helpers.showSnackBar(context, 'Not silindi');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noteAsync = ref.watch(noteByIdProvider(widget.note.id));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              widget.note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            ),
            onPressed: _togglePin,
            tooltip: widget.note.isPinned ? 'Sabitlemeyi Kaldır' : 'Sabitle',
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NoteEditScreen(note: widget.note),
                ),
              );
            },
            tooltip: 'Düzenle',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'summarize':
                  _summarizeNote();
                  break;
                case 'delete':
                  _deleteNote();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'summarize',
                child: Row(
                  children: [
                    Icon(
                      Icons.summarize_outlined,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    const Text('Özetle'),
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
        ],
      ),
      body: noteAsync.when(
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Not bulunamadı'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  note.title.isEmpty ? 'Başlıksız Not' : note.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Date
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Oluşturulma: ${Helpers.formatDateTime(note.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.update,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Güncellenme: ${Helpers.formatDateTime(note.updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                
                // Tags
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: note.tags.map((tag) {
                      return Chip(
                        avatar: Icon(
                          Icons.tag,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(tag),
                      );
                    }).toList(),
                  ),
                ],
                
                const Divider(height: 32),
                
                // Summary
                if (note.summary != null) ...[
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.summarize,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Özet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            note.summary!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Content
                Text(
                  note.content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Summarize Button
                if (note.summary == null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSummarizing ? null : _summarizeNote,
                      icon: _isSummarizing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.summarize_outlined),
                      label: Text(_isSummarizing ? 'Özetleniyor...' : 'Özetle'),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Hata oluştu')),
      ),
    );
  }
}
