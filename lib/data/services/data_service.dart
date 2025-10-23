import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:health_dashboard/data/model/journals_model.dart';
import 'package:health_dashboard/data/model/user_records_model.dart';

class DataService {
  final Random _random = Random();

  Future<T> _simulateNetworkCall<T>(Future<T> Function() callback) async {
    // Random latency between 700-1200ms
    final latency = 700 + _random.nextInt(501);
    await Future.delayed(Duration(milliseconds: latency));

    // ~10% chance of failure
    if (_random.nextDouble() < 0.1) {
      throw Exception('Network error: Failed to load data');
    }

    return await callback();
  }

  Future<List<BiometricData>> loadBiometrics({
    bool useLargeDataset = false,
  }) async {
    return _simulateNetworkCall(() async {
      final String response = await rootBundle.loadString(
        'assets/data/user_data.json',
      );
      final List<dynamic> data = json.decode(response);
      var biometrics = data
          .map((json) => BiometricData.fromJson(json))
          .toList();

      // Generate large dataset if requested
      if (useLargeDataset) {
        biometrics = _generateLargeDataset(biometrics);
      }

      return biometrics;
    });
  }

  Future<List<JournalEntry>> loadJournals() async {
    return _simulateNetworkCall(() async {
      final String response = await rootBundle.loadString(
        'assets/data/journals.json',
      );
      final List<dynamic> data = json.decode(response);
      return data.map((json) => JournalEntry.fromJson(json)).toList();
    });
  }

  List<BiometricData> _generateLargeDataset(List<BiometricData> base) {
    final result = <BiometricData>[];
    for (var entry in base) {
      // Add original entry
      result.add(entry);

      // Add 100+ synthetic entries between each day
      for (int i = 1; i <= 120; i++) {
        result.add(
          BiometricData(
            date: entry.date.add(Duration(minutes: i * 12)),
            hrv: entry.hrv != null
                ? entry.hrv! + (_random.nextDouble() - 0.5) * 5
                : null,
            rhr: entry.rhr != null ? entry.rhr! + _random.nextInt(3) - 1 : null,
            steps: entry.steps != null
                ? entry.steps! + _random.nextInt(100)
                : null,
            sleepScore: entry.sleepScore,
          ),
        );
      }
    }
    return result;
  }
}
