import 'package:flutter_test/flutter_test.dart';

// Example: function to format date
String formatDate(DateTime date) {
  return '${date.year}-${date.month}-${date.day}';
}

void main() {
  test('Date formatting works correctly', () {
    final date = DateTime(2025, 8, 14);
    expect(formatDate(date), '2025-8-14');
  });
}
