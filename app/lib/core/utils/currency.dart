import 'package:intl/intl.dart';

final _whole = NumberFormat.decimalPattern();
final _decimal = NumberFormat('#,##0.00');

/// `R1,450` — whole Rand, used for headline totals and tariffs.
String formatZar(num amount) => 'R${_whole.format(amount)}';

/// `R1,450.00` — used on line items and the quote breakdown, where the
/// designs show cents.
String formatZarExact(num amount) => 'R${_decimal.format(amount)}';

/// `R295/month` — a recurring storage price.
String formatZarMonthly(num amount) => '${formatZar(amount)}/month';

/// `R550 once-off` — a one-time service fee.
String formatZarOnceOff(num amount) => '${formatZar(amount)} once-off';
