import 'package:intl/intl.dart';

class DateFormattingHelper {
  static String formatDate(DateTime dateTime, {String locale = 'ru'}) {
    var format = DateFormat.yMd(locale); // DD.MM.YYYY
    return format.format(dateTime);
  }
}
