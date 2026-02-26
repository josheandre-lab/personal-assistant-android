import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
import '../providers/settings_provider.dart';
import '../services/summary_service.dart';
import '../services/export_service.dart';
import '../services/notification_service.dart';
import '../utils/helpers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: settings.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // Appearance Section
                _SectionHeader(title: 'Görünüm'),
                _ThemeSelector(
                  currentMode: settings.settings.themeMode,
                  onChanged: (mode) {
                    ref.read(settingsProvider.notifier).updateThemeMode(mode);
                  },
                ),

                const Divider(),

                // Notifications Section
                _SectionHeader(title: 'Bildirimler'),
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_active_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Günlük Brifing Bildirimi'),
                  subtitle: const Text('Her gün sabah planını hatırlat'),
                  value: settings.settings.dailyBriefingEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateDailyBriefing(value);
                  },
                ),
                if (settings.settings.dailyBriefingEnabled)
                  ListTile(
                    leading: const SizedBox(width: 40),
                    title: const Text('Brifing Saati'),
                    subtitle: Text(
                      Helpers.formatTimeOfDay(settings.settings.briefingTime),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _selectBriefingTime(context, ref),
                  ),

                const Divider(),

                // AI Section
                _SectionHeader(title: 'Yapay Zeka'),
                FutureBuilder<bool>(
                  future: SummaryService.hasAiKey(),
                  builder: (context, snapshot) {
                    final hasKey = snapshot.data ?? false;
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.auto_awesome,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('AI Özetleme'),
                          subtitle: Text(
                            hasKey
                                ? 'API anahtarı kayıtlı'
                                : 'API anahtarı eklenmemiş',
                          ),
                          trailing: hasKey
                              ? Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: () => _showAiSettingsDialog(context, ref),
                        ),
                        if (hasKey)
                          SwitchListTile(
                            secondary: const SizedBox(width: 40),
                            title: const Text('AI Kullan'),
                            subtitle: const Text(
                                'Özetleme ve brifing için AI kullan'),
                            value: settings.settings.useAiSummarization,
                            onChanged: (value) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .updateUseAiSummarization(value);
                            },
                          ),
                      ],
                    );
                  },
                ),

                const Divider(),

                // Data Section
                _SectionHeader(title: 'Veri'),
                ListTile(
                  leading: Icon(
                    Icons.download_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Verileri Dışa Aktar'),
                  subtitle: const Text('Not ve hatırlatmaları JSON olarak kaydet'),
                  onTap: () => _exportData(context),
                ),

                const Divider(),

                // About Section
                _SectionHeader(title: 'Hakkında'),
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Kişisel Asistan'),
                  subtitle: const Text('Versiyon 1.0.0'),
                ),
                ListTile(
                  leading: const SizedBox(width: 40),
                  title: const Text('Geliştirici'),
                  subtitle: const Text('Flutter + Material 3'),
                ),
              ],
            ),
    );
  }

  Future<void> _selectBriefingTime(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider).settings;
    final time = await showTimePicker(
      context: context,
      initialTime: settings.briefingTime,
    );

    if (time != null) {
      ref.read(settingsProvider.notifier).updateBriefingTime(time);
    }
  }

  Future<void> _showAiSettingsDialog(BuildContext context, WidgetRef ref) async {
    final apiKey = await SummaryService.getAiKey();
    final provider = await SummaryService.getProvider() ?? 'openai';

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => _AiSettingsDialog(
        initialApiKey: apiKey,
        initialProvider: provider,
        onSave: (key, prov) async {
          await ref.read(settingsProvider.notifier).updateAiKey(key);
          await ref.read(settingsProvider.notifier).updateAiProvider(prov);
        },
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      Helpers.showLoadingDialog(context, message: 'Veriler dışa aktarılıyor...');
      
      final filePath = await ExportService.exportAllData();
      
      if (context.mounted) {
        Helpers.hideLoadingDialog(context);
        
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Dışa Aktarma Tamamlandı'),
            content: const Text(
              'Verileriniz başarıyla dışa aktarıldı. Dosyayı paylaşmak ister misiniz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ExportService.shareExportedData(filePath);
                },
                child: const Text('Paylaş'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Helpers.hideLoadingDialog(context);
        Helpers.showSnackBar(
          context,
          'Dışa aktarma hatası: $e',
          isError: true,
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.light,
            label: Text('Açık'),
            icon: Icon(Icons.light_mode),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            label: Text('Koyu'),
            icon: Icon(Icons.dark_mode),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            label: Text('Sistem'),
            icon: Icon(Icons.settings_suggest),
          ),
        ],
        selected: {currentMode},
        onSelectionChanged: (set) {
          if (set.isNotEmpty) {
            onChanged(set.first);
          }
        },
      ),
    );
  }
}

class _AiSettingsDialog extends StatefulWidget {
  final String? initialApiKey;
  final String initialProvider;
  final Function(String? apiKey, String provider) onSave;

  const _AiSettingsDialog({
    this.initialApiKey,
    required this.initialProvider,
    required this.onSave,
  });

  @override
  State<_AiSettingsDialog> createState() => _AiSettingsDialogState();
}

class _AiSettingsDialogState extends State<_AiSettingsDialog> {
  late final TextEditingController _apiKeyController;
  late String _provider;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: widget.initialApiKey);
    _provider = widget.initialProvider;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI Ayarları'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Selection
            const Text('Sağlayıcı'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'openai',
                  label: Text('OpenAI'),
                ),
                ButtonSegment(
                  value: 'gemini',
                  label: Text('Gemini'),
                ),
              ],
              selected: {_provider},
              onSelectionChanged: (set) {
                if (set.isNotEmpty) {
                  setState(() {
                    _provider = set.first;
                  });
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // API Key
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'API Anahtarı',
                hintText: _provider == 'openai'
                    ? 'sk-...'
                    : 'Gemini API anahtarı',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    if (_apiKeyController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _apiKeyController.clear();
                        },
                      ),
                  ],
                ),
              ),
              obscureText: _obscureText,
            ),
            
            const SizedBox(height: 16),
            
            // Info
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bilgi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _provider == 'openai'
                          ? 'OpenAI API anahtarınızı OpenAI Dashboard\'dan alabilirsiniz.'
                          : 'Gemini API anahtarınızı Google AI Studio\'dan alabilirsiniz.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () {
            final key = _apiKeyController.text.trim();
            widget.onSave(key.isEmpty ? null : key, _provider);
            Navigator.pop(context);
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
