import 'package:health_dashboard/data/model/user_records_model.dart' show BiometricData;



class Decimator {
  // LTTB (Largest Triangle Three Buckets) algorithm
  // Downsamples data while preserving visual shape and trends
  static List<BiometricData> lttb(List<BiometricData> data, int threshold) {
    if (data.length <= threshold) return data;

    final result = <BiometricData>[data.first];
    final bucketSize = (data.length - 2) / (threshold - 2);

    int a = 0;
    for (int i = 0; i < threshold - 2; i++) {
      final avgRangeStart = ((i + 1) * bucketSize).floor() + 1;
      final avgRangeEnd = ((i + 2) * bucketSize).floor() + 1;
      final avgRangeEnd2 = avgRangeEnd < data.length
          ? avgRangeEnd
          : data.length;

      double avgX = 0;
      double avgY = 0;
      int avgRangeLength = avgRangeEnd2 - avgRangeStart;

      for (int j = avgRangeStart; j < avgRangeEnd2; j++) {
        avgX += data[j].date.millisecondsSinceEpoch.toDouble();
        avgY +=
            (data[j].hrv ??
            data[j].rhr?.toDouble() ??
            data[j].steps?.toDouble() ??
            0);
      }
      avgX /= avgRangeLength;
      avgY /= avgRangeLength;

      final rangeOffs = (i * bucketSize).floor() + 1;
      final rangeTo = ((i + 1) * bucketSize).floor() + 1;

      double maxArea = -1;
      int maxAreaPoint = rangeOffs;

      for (int j = rangeOffs; j < rangeTo; j++) {
        final yValue =
            data[j].hrv ??
            data[j].rhr?.toDouble() ??
            data[j].steps?.toDouble() ??
            0;
        final aYValue =
            data[a].hrv ??
            data[a].rhr?.toDouble() ??
            data[a].steps?.toDouble() ??
            0;

        final area =
            ((data[a].date.millisecondsSinceEpoch - avgX) * (yValue - aYValue) -
                    (data[a].date.millisecondsSinceEpoch -
                            data[j].date.millisecondsSinceEpoch) *
                        (avgY - aYValue))
                .abs();

        if (area > maxArea) {
          maxArea = area;
          maxAreaPoint = j;
        }
      }

      result.add(data[maxAreaPoint]);
      a = maxAreaPoint;
    }

    result.add(data.last);
    return result;
  }

  // Bucket mean - simpler alternative
  static List<BiometricData> bucketMean(List<BiometricData> data, int buckets) {
    if (data.length <= buckets) return data;

    final result = <BiometricData>[];
    final bucketSize = data.length / buckets;

    for (int i = 0; i < buckets; i++) {
      final start = (i * bucketSize).floor();
      final end = ((i + 1) * bucketSize).floor();
      final bucket = data.sublist(start, end < data.length ? end : data.length);

      if (bucket.isEmpty) continue;

      final avgHrv = bucket.where((d) => d.hrv != null).isEmpty
          ? null
          : bucket
                    .where((d) => d.hrv != null)
                    .map((d) => d.hrv!)
                    .reduce((a, b) => a + b) /
                bucket.where((d) => d.hrv != null).length;

      final avgRhr = bucket.where((d) => d.rhr != null).isEmpty
          ? null
          : (bucket
                        .where((d) => d.rhr != null)
                        .map((d) => d.rhr!)
                        .reduce((a, b) => a + b) /
                    bucket.where((d) => d.rhr != null).length)
                .round();

      final avgSteps = bucket.where((d) => d.steps != null).isEmpty
          ? null
          : (bucket
                        .where((d) => d.steps != null)
                        .map((d) => d.steps!)
                        .reduce((a, b) => a + b) /
                    bucket.where((d) => d.steps != null).length)
                .round();

      result.add(
        BiometricData(
          date: bucket[bucket.length ~/ 2].date,
          hrv: avgHrv,
          rhr: avgRhr,
          steps: avgSteps,
          sleepScore: bucket[bucket.length ~/ 2].sleepScore,
        ),
      );
    }

    return result;
  }
}