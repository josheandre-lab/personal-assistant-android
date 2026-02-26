import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (date == today) {
      return 'Bugün ${DateFormat('HH:mm').format(dateTime)}';
    } else if (date == today.subtract(const Duration(days: 1))) {
      return 'Dün ${DateFormat('HH:mm').format(dateTime)}';
    } else if (date == today.add(const Duration(days: 1))) {
      return 'Yarın ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm', 'tr_TR').format(dateTime);
    }
  }
  
  static String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (date == today) {
      return 'Bugün';
    } else if (date == today.subtract(const Duration(days: 1))) {
      return 'Dün';
    } else if (date == today.add(const Duration(days: 1))) {
      return 'Yarın';
    } else {
      return DateFormat('dd MMM yyyy', 'tr_TR').format(dateTime);
    }
  }
  
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
  
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} hafta önce';
    } else {
      return DateFormat('dd MMM yyyy', 'tr_TR').format(dateTime);
    }
  }
  
  static String getRepeatTypeText(String type) {
    switch (type) {
      case 'none':
        return 'Tekrar Yok';
      case 'daily':
        return 'Her Gün';
      case 'weekly':
        return 'Her Hafta';
      case 'monthly':
        return 'Her Ay';
      default:
        return 'Tekrar Yok';
    }
  }
  
  static List<String> extractTags(String text) {
    final regex = RegExp(r'#(\w+)');
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(1)!).toList();
  }
  
  static String highlightTags(String text, {TextStyle? style}) {
    return text;
  }
  
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return 'İyi Geceler';
    } else if (hour < 12) {
      return 'Günaydın';
    } else if (hour < 18) {
      return 'İyi Günler';
    } else {
      return 'İyi Akşamlar';
    }
  }
  
  static Future<void> showSnackBar(
    BuildContext context, 
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error 
            : Theme.of(context).colorScheme.primary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Evet',
    String cancelText = 'Hayır',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous 
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  
  static Future<void> showLoadingDialog(BuildContext context, {String? message}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message ?? 'Yükleniyor...'),
          ],
        ),
      ),
    );
  }
  
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
