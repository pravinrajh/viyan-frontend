/// INR display helpers for executive summaries.
abstract final class CurrencyFormatters {
  static String inr(num amount) {
    final value = amount.toDouble();
    final abs = value.abs();
    final sign = value < 0 ? '-' : '';
    if (abs >= 10000000) {
      return '$sign₹${(abs / 10000000).toStringAsFixed(2)} Cr';
    }
    if (abs >= 100000) {
      return '$sign₹${(abs / 100000).toStringAsFixed(2)} L';
    }
    return '$sign₹${abs.toStringAsFixed(0)}';
  }
}
