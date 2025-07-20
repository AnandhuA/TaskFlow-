import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final formatter = DateFormat('dd MMM yyyy, h:mm a');
  return formatter.format(date);
}
