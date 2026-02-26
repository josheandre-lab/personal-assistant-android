import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SummaryService {
  static const _secureStorage = FlutterSecureStorage();
  static const _apiKeyKey = 'ai_api_key';
  static const _providerKey = 'ai_provider';
  
  // Offline özetleme için anahtar kelimeler
  static const _turkishStopWords = {
    've', 'veya', 'ile', 'için', 'bu', 'şu', 'o', 'bir', 'iki', 'çok', 'az',
    'daha', 'en', 'gibi', 'kadar', 'her', 'tüm', 'tümü', 'bütün', 'hiç', 'de',
    'da', 'ki', 'mi', 'mı', 'mu', 'mü', 'ise', 'ya', 'eğer', 'ama', 'fakat',
    'lakin', 'çünkü', 'sonra', 'önce', 'şimdi', 'burada', 'orada', 'nerede',
    'nasıl', 'ne', 'kim', 'neden', 'niçin', 'niye', 'hangi', 'bana', 'sana',
    'ona', 'bunda', 'şunda', 'onda', 'ben', 'sen', 'o', 'biz', 'siz', 'onlar',
    'benim', 'senin', 'onun', 'bizim', 'sizin', 'onların', 'olan', 'olarak',
    'eden', 'etti', 'ettiği', 'oldu', 'olduğu', 'yapan', 'yaptı', 'yaptığı',
  };
  
  static Future<bool> hasAiKey() async {
    final key = await _secureStorage.read(key: _apiKeyKey);
    return key != null && key.isNotEmpty;
  }
  
  static Future<String?> getAiKey() async {
    return await _secureStorage.read(key: _apiKeyKey);
  }
  
  static Future<void> saveAiKey(String key) async {
    await _secureStorage.write(key: _apiKeyKey, value: key);
  }
  
  static Future<void> deleteAiKey() async {
    await _secureStorage.delete(key: _apiKeyKey);
  }
  
  static Future<String?> getProvider() async {
    return await _secureStorage.read(key: _providerKey);
  }
  
  static Future<void> saveProvider(String provider) async {
    await _secureStorage.write(key: _providerKey, value: provider);
  }
  
  static Future<String> summarize(String text, {bool useAi = false}) async {
    if (text.trim().isEmpty) {
      return 'Özetlenecek içerik bulunamadı.';
    }
    
    if (useAi && await hasAiKey()) {
      final provider = await getProvider() ?? 'openai';
      try {
        return await _summarizeWithAi(text, provider);
      } catch (e) {
        return _summarizeOffline(text);
      }
    }
    
    return _summarizeOffline(text);
  }
  
  static String _summarizeOffline(String text) {
    // Cümleleri ayır
    final sentences = _splitSentences(text);
    if (sentences.isEmpty) {
      return 'Özetlenecek içerik bulunamadı.';
    }
    
    if (sentences.length <= 3) {
      return sentences.join(' ');
    }
    
    // Kelime frekanslarını hesapla
    final wordFreq = _calculateWordFrequency(text);
    
    // Cümle skorlarını hesapla
    final sentenceScores = <String, double>{};
    for (final sentence in sentences) {
      sentenceScores[sentence] = _calculateSentenceScore(sentence, wordFreq);
    }
    
    // En yüksek skorlu cümleleri seç
    final sortedSentences = sentences.toList()
      ..sort((a, b) => sentenceScores[b]!.compareTo(sentenceScores[a]!));
    
    final summaryCount = sentences.length <= 5 ? 2 : 3;
    final topSentences = sortedSentences.take(summaryCount).toList();
    
    // Orijinal sıralamaya göre düzenle
    topSentences.sort((a, b) => 
      sentences.indexOf(a).compareTo(sentences.indexOf(b)));
    
    return topSentences.join(' ');
  }
  
  static List<String> _splitSentences(String text) {
    final sentences = <String>[];
    final regex = RegExp(r'[.!?]+');
    final parts = text.split(regex);
    
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.length > 10) {
        sentences.add(trimmed + '.');
      }
    }
    
    return sentences;
  }
  
  static Map<String, int> _calculateWordFrequency(String text) {
    final words = text.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'));
    
    final freq = <String, int>{};
    for (final word in words) {
      if (word.length > 2 && !_turkishStopWords.contains(word)) {
        freq[word] = (freq[word] ?? 0) + 1;
      }
    }
    
    return freq;
  }
  
  static double _calculateSentenceScore(
    String sentence, 
    Map<String, int> wordFreq
  ) {
    final words = sentence.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'));
    
    if (words.isEmpty) return 0;
    
    double score = 0;
    for (final word in words) {
      if (wordFreq.containsKey(word)) {
        score += wordFreq[word]!;
      }
    }
    
    // Cümle uzunluğuna göre normalize et
    score = score / words.length;
    
    // İlk cümleye bonus ver
    if (sentence == words.first) {
      score *= 1.2;
    }
    
    return score;
  }
  
  static Future<String> _summarizeWithAi(String text, String provider) async {
    final apiKey = await getAiKey();
    if (apiKey == null) throw Exception('API anahtarı bulunamadı');
    
    switch (provider) {
      case 'openai':
        return _summarizeWithOpenAI(text, apiKey);
      case 'gemini':
        return _summarizeWithGemini(text, apiKey);
      default:
        throw Exception('Bilinmeyen sağlayıcı: $provider');
    }
  }
  
  static Future<String> _summarizeWithOpenAI(String text, String apiKey) async {
    const url = 'https://api.openai.com/v1/chat/completions';
    
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'Sen bir metin özetleme asistanısın. Verilen metni 3-5 cümleyle özetiyle.'
          },
          {
            'role': 'user',
            'content': 'Şu metni özetle: $text'
          }
        ],
        'max_tokens': 200,
        'temperature': 0.5,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('OpenAI API hatası: ${response.statusCode}');
    }
  }
  
  static Future<String> _summarizeWithGemini(String text, String apiKey) async {
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';
    
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': 'Şu metni 3-5 cümleyle özetiyle: $text'
              }
            ]
          }
        ],
        'generationConfig': {
          'maxOutputTokens': 200,
          'temperature': 0.5,
        },
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'].trim();
    } else {
      throw Exception('Gemini API hatası: ${response.statusCode}');
    }
  }
  
  static Future<String> generateDailyBriefing({
    required List<String> reminders,
    required List<String> notes,
    bool useAi = false,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('📅 BUGÜNKÜ PLANIN');
    buffer.writeln('');
    
    if (reminders.isNotEmpty) {
      buffer.writeln('📝 Hatırlatmalar:');
      for (int i = 0; i < reminders.length; i++) {
        buffer.writeln('${i + 1}. ${reminders[i]}');
      }
      buffer.writeln('');
    }
    
    if (notes.isNotEmpty) {
      buffer.writeln('📌 Son Notlar:');
      for (int i = 0; i < notes.length && i < 3; i++) {
        buffer.writeln('• ${notes[i]}');
      }
    }
    
    final briefingText = buffer.toString();
    
    if (useAi && await hasAiKey() && (reminders.isNotEmpty || notes.isNotEmpty)) {
      try {
        final provider = await getProvider() ?? 'openai';
        return await _generateAiBriefing(reminders, notes, provider);
      } catch (e) {
        return briefingText;
      }
    }
    
    return briefingText;
  }
  
  static Future<String> _generateAiBriefing(
    List<String> reminders, 
    List<String> notes,
    String provider
  ) async {
    final apiKey = await getAiKey();
    if (apiKey == null) throw Exception('API anahtarı bulunamadı');
    
    final prompt = '''
Bugün için şu hatırlatmalarım ve notlarım var:

Hatırlatmalar:
${reminders.map((r) => '- $r').join('\n')}

Son Notlar:
${notes.take(3).map((n) => '- $n').join('\n')}

Bana motive edici ve yapıcı bir günlük brifing hazırla. Günün önemini vurgula ve önceliklerimi hatırlat.
''';
    
    if (provider == 'openai') {
      const url = 'https://api.openai.com/v1/chat/completions';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'Sen motive edici bir kişisel asistansın. Kullanıcının gününü planlamasına yardımcı ol.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      }
    } else if (provider == 'gemini') {
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt
                }
              ]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': 300,
            'temperature': 0.7,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'].trim();
      }
    }
    
    throw Exception('AI brifing oluşturulamadı');
  }
}
