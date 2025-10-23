import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_dashboard/helpers/theming/theme_provider.dart';
import 'package:health_dashboard/presentations/dashboard/data/dashboard_provider.dart';
import 'package:provider/provider.dart';

class RangeControls extends StatelessWidget {
  final TimeRange selectedRange;
  final Function(TimeRange) onRangeChanged;

  const RangeControls({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 150.w,
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.isDarkMode ? Colors.grey[850] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildRangeButton(
                    context,
                    '7D',
                    TimeRange.days7,
                    theme.isDarkMode,
                  ),
                ),
                Expanded(
                  child: _buildRangeButton(
                    context,
                    '30D',
                    TimeRange.days30,
                    theme.isDarkMode,
                  ),
                ),
                Expanded(
                  child: _buildRangeButton(
                    context,
                    '90D',
                    TimeRange.days90,
                    theme.isDarkMode,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRangeButton(
    BuildContext context,
    String label,
    TimeRange range,
    bool isDark,
  ) {
    final isSelected = selectedRange == range;

    return InkWell(
      onTap: () => onRangeChanged(range),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
