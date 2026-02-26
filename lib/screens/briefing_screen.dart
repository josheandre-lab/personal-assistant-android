import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../services/summary_service.dart';
import '../utils/helpers.dart';

class BriefingScreen extends ConsumerStatefulWidget {
  const BriefingScreen({super.key});

  @override
  ConsumerState<BriefingScreen> createState() => _BriefingScreenState();
}

class _BriefingScreenState extends ConsumerState<BriefingScreen> {
  String? _briefing;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _generateBriefing();
  }

  Future<void> _generateBriefing() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final reminderRepo = await ref.read(reminderRepositoryProvider.future);
      final noteRepo = await ref.read(noteRepositoryProvider.future);

      final todaysReminders = await reminderRepo.getTodaysReminders();
      final recentNotes = await noteRepo.getRecentNotes(limit: 5);

      final useAi = ref.read(useAiSummarizationProvider);

      final briefing = await SummaryService.generateDailyBriefing(
        reminders: todaysReminders.map((r) => r.title).toList(),
        notes: recentNotes.map((n) => n.title).toList(),
        useAi: useAi,
      );

      if (mounted) {
        setState(() {
          _briefing = briefing;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _briefing = 'Brifing oluşturulurken bir hata oluştu.';
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _copyToClipboard() async {
    if (_briefing != null) {
      await Clipboard.setData(ClipboardData(text: _briefing!));
      if (mounted) {
        Helpers.showSnackBar(context, 'Panoya kopyalandı');
      }
    }
  }

  Future<void> _shareBriefing() async {
    // Share functionality would be implemented here
    if (mounted) {
      Helpers.showSnackBar(context, 'Paylaşım özelliği yakında geliyor');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useAi = ref.watch(useAiSummarizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Brifing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isGenerating ? null : _generateBriefing,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isGenerating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Brifing oluşturuluyor...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
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
                                Icons.wb_sunny,
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Helpers.getGreeting(),
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                        color: theme.colorScheme
                                            .onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      Helpers.formatDate(DateTime.now()),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: theme.colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Briefing Content
                  if (_briefing != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Bugünün Planı',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (useAi)
                                  Chip(
                                    label: const Text('AI'),
                                    avatar: Icon(
                                      Icons.auto_awesome,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                              ],
                            ),
                            const Divider(height: 24),
                            SelectableText(
                              _briefing!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _copyToClipboard,
                            icon: const Icon(Icons.copy),
                            label: const Text('Kopyala'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _shareBriefing,
                            icon: const Icon(Icons.share),
                            label: const Text('Paylaş'),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Tips Card
                  Card(
                    color: theme.colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'İpucu',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            useAi
                                ? 'AI özetleme aktif. Daha iyi sonuçlar için Ayarlar\'dan API anahtarınızı kontrol edin.'
                                : 'Daha gelişmiş brifingler için Ayarlar\'dan AI özetlemeyi aktif edebilirsiniz.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
