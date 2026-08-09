import 'package:intl/intl.dart';

/// Data relativa feed/commenti: ore fa → g → data assoluta.
String formatFeedRelativeDate(int? unixSeconds) {
  if (unixSeconds == null || unixSeconds <= 0) return '';
  final date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return 'adesso';
  if (diff.inHours < 1) return '${diff.inMinutes} min fa';
  if (diff.inDays < 1) return '${diff.inHours} ore fa';
  if (diff.inDays < 7) return '${diff.inDays} g';
  return DateFormat('d MMM yyyy').format(date);
}

/// Data header card feed (relativa).
String formatOmnifeedCardDate(int? unixSeconds) {
  return formatFeedRelativeDate(unixSeconds);
}

/// Data in stile web OmniFeed (header card).
String formatOmnifeedHeaderDate(int? unixSeconds) {
  if (unixSeconds == null || unixSeconds <= 0) return '';
  final date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
  return DateFormat('d MMM yyyy, HH:mm').format(date);
}

String formatOmnifeedDate(int? unixSeconds) {
  return formatFeedRelativeDate(unixSeconds);
}

/// Data relativa nei commenti (stesso formato dell'header feed).
String formatFeedCommentDate(int? unixSeconds) {
  return formatFeedRelativeDate(unixSeconds);
}
