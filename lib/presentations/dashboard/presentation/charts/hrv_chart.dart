// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:health_dashboard/data/model/user_records_model.dart';

class DisplayHRVChart extends StatefulWidget {
  const DisplayHRVChart({
    Key? key,
    required this.data,
    required this.rollingMean,
    required this.isDark,
    required this.zoomPanBehavior,
    required this.trackballBehavior,
    required this.annotations,
    required this.onChartTouchInteractionDown
  }) : super(key: key);

  final List<BiometricData> data;
  final List<BiometricData> rollingMean;
  final bool isDark;
  final ZoomPanBehavior? zoomPanBehavior;
  final TrackballBehavior? trackballBehavior;
  final List<CartesianChartAnnotation>? annotations;
  final void Function(ChartTouchInteractionArgs)? onChartTouchInteractionDown;

  @override
  State<DisplayHRVChart> createState() => _DisplayHRVChartState();
}

class _DisplayHRVChartState extends State<DisplayHRVChart> {
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
          width: 0.5,
          color: widget.isDark ? Colors.white12 : Colors.black12,
        ),
        axisLine: const AxisLine(width: 0),
        labelStyle: TextStyle(
          color: widget.isDark ? Colors.white70 : Colors.black54,
          fontSize: 11,
        ),
      ),
      annotations: widget.annotations,
      series: <CartesianSeries>[
        if (widget.rollingMean.isNotEmpty)
          SplineSeries<BiometricData, DateTime>(
            dataSource: widget.rollingMean,
            xValueMapper: (d, _) => d.date,
            yValueMapper: (d, _) => d.hrv,
            color: const Color(0xFF00BCD4).withValues(alpha: 0.5),
            width: 2,
            dashArray: const [5, 5],
            name: '7-day mean',
          ),
        SplineSeries<BiometricData, DateTime>(
          dataSource: widget.data,
          xValueMapper: (d, _) => d.date,
          yValueMapper: (d, _) => d.hrv,
          color: const Color(0xFF00BCD4),
          width: 3,
          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 6,
            width: 6,
            borderWidth: 2,
            borderColor: Colors.white,
          ),
          name: 'HRV',
        ),
      ],
      onChartTouchInteractionDown: widget.onChartTouchInteractionDown
    );
    
  }
}
