import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final formatter = DateFormat('dd MMM yyyy, h:mm a');
  return formatter.format(date);
}

String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }