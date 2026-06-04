import 'package:intl/intl.dart';

String formatOmnifeedDate(int? unixSeconds) {
  if (unixSeconds == null || unixSeconds <= 0) return '';
  final date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return 'adesso';
  if (diff.inHours < 1) return '${diff.inMinutes} min fa';
  if (diff.inDays < 1) return '${diff.inHours} h fa';
  if (diff.inDays < 7) return '${diff.inDays} g fa';
  return DateFormat('d MMM yyyy').format(date);
}
