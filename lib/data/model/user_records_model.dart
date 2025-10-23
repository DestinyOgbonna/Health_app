class BiometricData {
  final DateTime date;
  final double? hrv;
  final num? rhr;
  final num? steps;
  final num? sleepScore;

  BiometricData({
    required this.date,
    this.hrv,
    this.rhr,
    this.steps,
    this.sleepScore,
  });

  factory BiometricData.fromJson(Map<String, dynamic> json) {
    return BiometricData(
      date: DateTime.parse(json['date']),
      hrv: json['hrv']?.toDouble(),
      rhr: json['rhr']?.toInt(),
      steps: json['steps'],
      sleepScore: json['sleepScore'],
    );
  }
}