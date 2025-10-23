import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_dashboard/data/model/user_records_model.dart';
import 'package:health_dashboard/helpers/theming/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RHRChartScreen extends StatefulWidget {
  const RHRChartScreen({
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
  State<RHRChartScreen> createState() => _RHRChartScreenState();
}

class _RHRChartScreenState extends State<RHRChartScreen> {
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
          color: Provider.of<ThemeProvider>(context, listen: false).isDarkMode
              ? Colors.white12
              : Colors.black12,
        ),
        axisLine: const AxisLine(width: 0),
        labelStyle: TextStyle(
          color: widget.isDark ? Colors.white70 : Colors.black54,
          fontSize: 11,
        ),
      ),
      series: <CartesianSeries>[
        AreaSeries<BiometricData, DateTime>(
          dataSource: widget.data,
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
}
