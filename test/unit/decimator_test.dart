import 'package:flutter_test/flutter_test.dart';
import 'package:health_dashboard/data/decimator/decimator.dart';
import 'package:health_dashboard/data/model/user_records_model.dart';

List<BiometricData> generateTestData(int count) {
  final baseDate = DateTime(2025, 1, 1);
  return List.generate(count, (i) {
    return BiometricData(
      date: baseDate.add(Duration(days: i)),
      hrv: 50 + (i % 20).toDouble(),
      rhr: 60 + (i % 10),
      steps: 5000 + (i * 100),
      sleepScore: 70 + (i % 20),
    );
  });
}

void main() {
  group('Decimator LTTB Algorithm', () {
    test('preserves exact output size when decimating', () {
      final data = generateTestData(1000);
      final threshold = 100;

      final result = Decimator.lttb(data, threshold);

      expect(
        result.length,
        equals(threshold),
        reason: 'LTTB should produce exactly $threshold points',
      );
    });

    test('preserves min/max values in output', () {
      final data = generateTestData(500);
      final threshold = 50;

      // Find min and max HRV values
      final originalMinHrv = data
          .map((d) => d.hrv!)
          .reduce((a, b) => a < b ? a : b);
      final originalMaxHrv = data
          .map((d) => d.hrv!)
          .reduce((a, b) => a > b ? a : b);

      final result = Decimator.lttb(data, threshold);

      final resultMinHrv = result
          .map((d) => d.hrv!)
          .reduce((a, b) => a < b ? a : b);
      final resultMaxHrv = result
          .map((d) => d.hrv!)
          .reduce((a, b) => a > b ? a : b);

      expect(
        resultMinHrv,
        lessThanOrEqualTo(originalMinHrv + 5),
        reason: 'Min value should be preserved or close',
      );
      expect(
        resultMaxHrv,
        greaterThanOrEqualTo(originalMaxHrv - 5),
        reason: 'Max value should be preserved or close',
      );
    });

   
  });
}
