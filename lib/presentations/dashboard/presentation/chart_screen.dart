import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_dashboard/data/decimator/decimator.dart';
import 'package:health_dashboard/data/model/journals_model.dart';
import 'package:health_dashboard/data/model/user_records_model.dart';
import 'package:health_dashboard/helpers/mood_indicator.dart';
import 'package:health_dashboard/helpers/theming/theme_provider.dart';
import 'package:health_dashboard/presentations/dashboard/data/dashboard_provider.dart';
import 'package:health_dashboard/presentations/dashboard/presentation/charts/hrv_chart.dart';
import 'package:health_dashboard/presentations/dashboard/presentation/journal_dropdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SynchronizedBiometricCharts extends StatefulWidget {
  final List<BiometricData> data;
  final List<JournalEntry> journals;
  final TimeRange timeRange;

  const SynchronizedBiometricCharts({
    super.key,
    required this.data,
    required this.journals,
    required this.timeRange,
  });

  @override
  State<SynchronizedBiometricCharts> createState() =>
      _SynchronizedBiometricChartsState();
}

class _SynchronizedBiometricChartsState
    extends State<SynchronizedBiometricCharts> {
  late TrackballBehavior _trackballBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  JournalEntry? _selectedJournal;

  @override
  void initState() {
    super.initState();
    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      tooltipSettings: const InteractiveTooltip(
        enable: true,
        color: Colors.grey,
        canShowMarker: true,
      ),
    );
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      zoomMode: ZoomMode.x,
      enableDoubleTapZooming: true,
      enableSelectionZooming: true,
      enableMouseWheelZooming: true,
      maximumZoomLevel: 0.6,
    );
  }

  void _showJournalDetails(JournalEntry journal) {
    setState(() {
      _selectedJournal = journal;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JournalDetailsSheet(journal: journal),
    );
  }

  List<BiometricData> _getFilteredData() {
    if (widget.data.isEmpty) return [];

    final now = widget.data.last.date;
    int daysToShow;

    switch (widget.timeRange) {
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
    var filtered = widget.data
        .where((d) => d.date.isAfter(cutoffDate))
        .toList();
    if (widget.timeRange == TimeRange.days30 && filtered.length > 500) {
      filtered = Decimator.lttb(filtered, 500);
    } else if (widget.timeRange == TimeRange.days90 && filtered.length > 1000) {
      filtered = Decimator.lttb(filtered, 1000);
    }
    return filtered;
  }

  List<BiometricData> _calculateRollingMean(List<BiometricData> data) {
    if (data.length < 7) return [];

    final result = <BiometricData>[];
    for (int i = 6; i < data.length; i++) {
      final window = data.sublist(i - 6, i + 1);
      final validHrvValues = window
          .where((d) => d.hrv != null)
          .map((d) => d.hrv!)
          .toList();

      if (validHrvValues.isNotEmpty) {
        final mean =
            validHrvValues.reduce((a, b) => a + b) / validHrvValues.length;
        result.add(BiometricData(date: data[i].date, hrv: mean));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _getFilteredData();
    final rollingMean = _calculateRollingMean(filteredData);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Skeletonizer(
          enabled: Provider.of<DashboardState>(
            context,
            listen: false,
          ).isLoading,
          ignoreContainers: true,
          effect: ShimmerEffect(baseColor: Colors.grey),
          child: Consumer<ThemeProvider>(
            builder: (context, themes, _) {
              bool isSmallScreen = constraints.maxWidth < 1300;
              return isSmallScreen
                  ? Column(
                      children: [
                        Container(
                          child: _buildChartCard(
                            context,
                            'Heart Rate Variability (HRV)',
                            'ms',
                            DisplayHRVChart(
                              data: filteredData,
                              rollingMean: rollingMean,
                              isDark: themes.isDarkMode,
                              zoomPanBehavior: _zoomPanBehavior,
                              trackballBehavior: _trackballBehavior,
                              onChartTouchInteractionDown:
                                  (ChartTouchInteractionArgs args) {
                                    //     _handleChartTap(args, widget.data);
                                  },
                              annotations: [
                                ..._buildJournalAnnotations(
                                  filteredData,
                                  themes.isDarkMode,
                                ),
                              ],
                            ),
                            themes.isDarkMode,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildChartCard(
                          context,
                          'Resting Heart Rate (RHR)',
                          'bpm',

                          _buildRHRChart(filteredData, themes.isDarkMode),
                          themes.isDarkMode,
                        ),
                        const SizedBox(height: 16),
                        _buildChartCard(
                          context,
                          'Daily Steps',
                          'steps',
                          _buildStepsChart(filteredData, themes.isDarkMode),
                          themes.isDarkMode,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(30),
                            width: 700,
                            height: 650,
                            child: _buildChartCard(
                              context,
                              'Heart Rate Variability (HRV)',
                              'ms',
                              DisplayHRVChart(
                                data: filteredData,
                                rollingMean: rollingMean,
                                isDark: themes.isDarkMode,
                                zoomPanBehavior: _zoomPanBehavior,
                                trackballBehavior: _trackballBehavior,
                                onChartTouchInteractionDown:
                                    (ChartTouchInteractionArgs args) {},
                                annotations: [
                                  ..._buildJournalAnnotations(
                                    filteredData,
                                    themes.isDarkMode,
                                  ),
                                ],
                              ),
                              themes.isDarkMode,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(30),
                            width: 700,
                            height: 650,
                            child: _buildChartCard(
                              context,
                              'Resting Heart Rate (RHR)',
                              'bpm',

                              _buildRHRChart(filteredData, themes.isDarkMode),
                              themes.isDarkMode,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(30),
                            width: 700,
                            height: 650,
                            child: _buildChartCard(
                              context,
                              'Daily Steps',
                              'steps',
                              _buildStepsChart(filteredData, themes.isDarkMode),
                              themes.isDarkMode,
                            ),
                          ),
                        ),
                      ],
                    );
            },
          ),
        );
      },
    );
  }

  Widget _buildChartCard(
    BuildContext context,
    String title,
    String unit,
    Widget chart,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  unit,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 450, child: chart),
        ],
      ),
    );
  }

  List<CartesianChartAnnotation> _buildJournalAnnotations(
    List<BiometricData> data,
    bool isDark,
  ) {
    final annotations = <CartesianChartAnnotation>[];

    for (final journal in widget.journals) {
      final dataPoint = data
          .where(
            (d) =>
                d.date.year == journal.date.year &&
                d.date.month == journal.date.month &&
                d.date.day == journal.date.day,
          )
          .firstOrNull;

      if (dataPoint != null && dataPoint.hrv != null) {
        final bool isSelected = _selectedJournal?.date == journal.date;

        annotations.add(
          CartesianChartAnnotation(
            widget: GestureDetector(
              onTap: () => _showJournalDetails(journal),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mood indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 28 : 20,
                    height: isSelected ? 28 : 20,
                    decoration: BoxDecoration(
                      color: _getMoodColor(journal.mood as int),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _getMoodColor(
                                  journal.mood as int,
                                ).withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        getMoodEmoji(journal.mood as int),
                        style: GoogleFonts.montserrat(
                          fontSize: isSelected ? 14 : 10,
                        ),
                      ),
                    ),
                  ),
                  // Vertical line
                  Container(
                    width: 2,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _getMoodColor(
                            journal.mood as int,
                          ).withValues(alpha: 0.7),
                          _getMoodColor(
                            journal.mood as int,
                          ).withValues(alpha: 0.01),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            coordinateUnit: CoordinateUnit.point,
            x: journal.date,
            y: dataPoint.hrv! + 5, // Position above data point
          ),
        );
      }
    }

    return annotations;
  }

  Color _getMoodColor(int mood) {
    switch (mood) {
      case 1:
        return const Color(0xFFEF5350);
      case 2:
        return const Color(0xFFFF9800);
      case 3:
        return const Color(0xFFFFC107);
      case 4:
        return const Color(0xFF66BB6A);
      case 5:
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  Widget _buildRHRChart(List<BiometricData> data, bool isDark) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      trackballBehavior: _trackballBehavior,
      zoomPanBehavior: _zoomPanBehavior,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        textStyle: GoogleFonts.montserrat(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 12,
        ),
      ),
      primaryXAxis: DateTimeAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelStyle: TextStyle(
          color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode
              ? Colors.white70
              : Colors.black54,
          fontSize: 11,
        ),
        dateFormat: DateFormat('MMM dd'),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(
          width: 0.5,
          color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode
              ? Colors.white12
              : Colors.black12,
        ),
        axisLine: const AxisLine(width: 0),
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 11,
        ),
      ),
      series: <CartesianSeries>[
        AreaSeries<BiometricData, DateTime>(
          dataSource: data,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.rhr,
          color: Colors.lightBlueAccent,
          borderWidth: 3,
          borderColor: Colors.lightBlueAccent,
          gradient: LinearGradient(
            colors: [
              const Color(0xff90E0EF).withValues(alpha: 0.5),
              const Color(0xff90E0EF).withValues(alpha: 0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 6,
            width: 6,
            borderWidth: 2,
            borderColor: Colors.white,
          ),
          name: 'RHR',
        ),
      ],
    );
  }

  Widget _buildStepsChart(List<BiometricData> data, bool isDark) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      trackballBehavior: _trackballBehavior,
      zoomPanBehavior: _zoomPanBehavior,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        textStyle: GoogleFonts.montserrat(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 12,
        ),
      ),
      primaryXAxis: DateTimeAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 11,
        ),
        dateFormat: DateFormat('MMM dd'),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(
          width: 0.3,
          color: isDark ? Colors.white12 : Colors.black12,
        ),
        axisLine: const AxisLine(width: 0),
        labelStyle: GoogleFonts.montserrat(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 11,
        ),
      ),
      series: <CartesianSeries>[
        ColumnSeries<BiometricData, DateTime>(
          dataSource: data,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.steps,
          color: const Color(0xFF66BB6A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          gradient: LinearGradient(
            colors: [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          name: 'Steps',
        ),
      ],
    );
  }
}
