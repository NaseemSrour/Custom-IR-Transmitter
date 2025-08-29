import 'package:intl/intl.dart';

String formatDateString(String date) {
  DateTime dateTime = DateTime.parse(date);
  final DateFormat formatter = DateFormat('HH:mm  dd-MM-yyy');
  final String formatted = formatter.format(dateTime);
  return formatted;
}
