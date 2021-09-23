import 'package:intl/intl.dart';

class NumberFormattingHelper {
  static String format(double number) {
    return NumberFormat.decimalPattern().format(number);
  }

  static String currency(double number) {
    return NumberFormat.currency(locale: 'en', symbol: '\$', decimalDigits: 0)
        .format(number);
  }
}
