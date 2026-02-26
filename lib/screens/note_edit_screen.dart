import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../providers/database_provider.dart';
import '../utils/helpers.dart';

class NoteEditScreen extends ConsumerStatefulWidget {
  final Note? note;

  const NoteEditScreen({
    super.key,
    this.note,
  });

  @override
  ConsumerState<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends ConsumerState<NoteEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagController;
  final List<String> _tags = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _tagController = TextEditingController();
    if (widget.note != null) {
      _tags.addAll(widget.note!.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveNote() async {
    if (_contentController.text.trim().isEmpty) {
      Helpers.showSnackBar(
        context,
        'Not içeriği boş olamaz',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = await ref.read(noteRepositoryProvider.future);
      
      final note = widget.note ?? Note(title: '', content: '');
      note.title = _titleController.text.trim();
      note.content = _contentController.text.trim();
      note.tags = List.from(_tags);

      await repo.saveNote(note);
      ref.invalidate(notesProvider);
      ref.invalidate(recentNotesProvider);

      if (mounted) {
        Navigator.of(context).pop();
        Helpers.showSnackBar(
          context,
          widget.note == null ? 'Not oluşturuldu' : 'Not güncellendi',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Notu Düzenle' : 'Yeni Not'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveNote,
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
                hintText: 'Başlık (opsiyonel)',
                prefixIcon: Icon(Icons.title),
              ),
              style: theme.textTheme.titleLarge,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 16),
            
            // Content
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'Notunuzu buraya yazın...',
                alignLabelWithHint: true,
              ),
              style: theme.textTheme.bodyLarge,
              maxLines: null,
              minLines: 10,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 24),
            
            // Tags Section
            Text(
              'Etiketler',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Add Tag
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'Etiket ekle (#etiket)',
                      prefixIcon: Icon(Icons.tag),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Tags List
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return InputChip(
                    label: Text('#$tag'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
              )
            else
              Text(
                'Henüz etiket eklenmemiş',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Extract Tags from Content
            if (_contentController.text.contains('#'))
              OutlinedButton.icon(
                onPressed: () {
                  final extractedTags = Helpers.extractTags(
                    _contentController.text,
                  );
                  for (final tag in extractedTags) {
                    if (!_tags.contains(tag)) {
                      setState(() {
                        _tags.add(tag);
                      });
                    }
                  }
                  if (extractedTags.isNotEmpty && mounted) {
                    Helpers.showSnackBar(
                      context,
                      '${extractedTags.length} etiket eklendi',
                    );
                  }
                },
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('İçerikten Etiketleri Çıkar'),
              ),
          ],
        ),
      ),
    );
  }
}
