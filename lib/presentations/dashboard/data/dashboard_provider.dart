import 'package:flutter/widgets.dart';
import 'package:health_dashboard/data/model/journals_model.dart';
import 'package:health_dashboard/data/model/user_records_model.dart';
import 'package:health_dashboard/data/services/data_service.dart';

class DashboardState extends ChangeNotifier {
  final DataService _dataService = DataService();

  List<BiometricData>? _biometrics;
  List<JournalEntry>? _journals;
  bool _isLoading = true;
  String? _error;
  TimeRange _selectedRange = TimeRange.days7;
  bool _useLargeDataset = false;
  int _fps = 60;

  List<BiometricData>? get biometrics => _biometrics;
  List<JournalEntry>? get journals => _journals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TimeRange get selectedRange => _selectedRange;
  bool get useLargeDataset => _useLargeDataset;
  int get fps => _fps;
  int get dataPointCount => _biometrics?.length ?? 0;
  int get displayedPointCount {
    if (_biometrics == null) return 0;

    final now = _biometrics!.last.date;
    int daysToShow;

    switch (_selectedRange) {
      case TimeRange.days7:
        daysToShow = 7;
        break;
      case TimeRange.days30:
        daysToShow = 30;
        break;
      case TimeRange.days90:
        daysToShow = 90;
        break;
    }

    final cutoffDate = now.subtract(Duration(days: daysToShow));
    var filtered = _biometrics!
        .where((d) => d.date.isAfter(cutoffDate))
        .toList();

    // Apply same decimation logic
    if (_selectedRange == TimeRange.days30 && filtered.length > 500) {
      return 500;
    } else if (_selectedRange == TimeRange.days90 && filtered.length > 1000) {
      return 1000;
    }

    return filtered.length;
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _dataService.loadBiometrics(useLargeDataset: _useLargeDataset),
        _dataService.loadJournals(),
      ]);

      _biometrics = results[0] as List<BiometricData>;
      _journals = results[1] as List<JournalEntry>;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTimeRange(TimeRange range) {
    _selectedRange = range;
    notifyListeners();
  }

  void toggleLargeDataset() {
    _useLargeDataset = !_useLargeDataset;
    loadData();
  }

  void retry() {
    loadData();
  }
}

enum TimeRange { days7, days30, days90 }
