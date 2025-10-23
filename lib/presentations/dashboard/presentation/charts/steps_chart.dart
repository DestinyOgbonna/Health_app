import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_dashboard/data/model/user_records_model.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StepsChartScreen extends StatefulWidget {
  const StepsChartScreen({
    super.key,
    required this.data,
    required this.isDark,
    this.zoomPanBehavior,
    this.trackballBehavior,
  });

  final List<BiometricData> data;
  final bool isDark;
  final ZoomPanBehavior? zoomPanBehavior;
  final TrackballBehavior? trackballBehavior;

  @override
  State<StepsChartScreen> createState() => _StepsChartScreenState();
}

class _StepsChartScreenState extends State<StepsChartScreen> {
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      trackballBehavior: widget.trackballBehavior,
      zoomPanBehavior: widget.zoomPanBehavior,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        textStyle: GoogleFonts.montserrat(
          color: widget.isDark ? Colors.white70 : Colors.black54,
          fontSize: 12,
        ),
      ),
      primaryXAxis: DateTimeAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelStyle: TextStyle(
          color: widget.isDark ? Colors.white70 : Colors.black54,
          fontSize: 11,
        ),
        dateFormat: DateFormat('MMM dd'),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(
          width: 0.3,
          color: widget.isDark ? Colors.white12 : Colors.black12,
        ),
        axisLine: const AxisLine(width: 0),
        labelStyle: GoogleFonts.montserrat(
          color: widget.isDark ? Colors.white70 : Colors.black54,
          fontSize: 11,
        ),
      ),
      series: <CartesianSeries>[
        ColumnSeries<BiometricData, DateTime>(
          dataSource: widget.data,
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
