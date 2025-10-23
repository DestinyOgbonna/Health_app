import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_dashboard/data/model/journals_model.dart';
import 'package:health_dashboard/helpers/mood_indicator.dart';
import 'package:health_dashboard/helpers/theming/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class JournalDetailsSheet extends StatefulWidget {
  final JournalEntry journal;

  const JournalDetailsSheet({super.key, required this.journal});

  @override
  State<JournalDetailsSheet> createState() => _JournalDetailsSheetState();
}

class _JournalDetailsSheetState extends State<JournalDetailsSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>( 
      builder: (context, theme, _) {
        return Container(
          decoration: BoxDecoration(
            color: theme.isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with mood indicator
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getMoodColor(
                              widget.journal.mood as int,
                            ).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              getMoodEmoji(widget.journal.mood as int),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getMoodLabel(widget.journal.mood as int),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23,

                                  color: theme.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'EEEE, MMMM d, y',
                                ).format(widget.journal.date),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,

                                  color: theme.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Divider(
                      color: theme.isDarkMode
                          ? Colors.grey[800]
                          : Colors.lightBlue,
                    ),

                    const SizedBox(height: 16),

                    // Note label
                    Row(
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Journal Note',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,

                            color: theme.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Note content
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? Colors.grey[850]
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.isDarkMode
                              ? Colors.grey[800]!
                              : Colors.lightBlue,
                        ),
                      ),
                      child: Text(
                        widget.journal.note,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: theme.isDarkMode
                              ? Colors.white70
                              : Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Mood scale indicator
                    _buildMoodScale(theme.isDarkMode),

                    const SizedBox(height: 24),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.isDarkMode
                              ? Colors.grey[800]
                              : Colors.lightBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.isDarkMode
                                ? Colors.white70
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodScale(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Scale',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final moodValue = index + 1;
            final isSelected = moodValue == widget.journal.mood;

            return Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 44 : 36,
                  height: isSelected ? 44 : 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getMoodColor(moodValue)
                        : (isDark ? Colors.grey[800] : Colors.lightBlue),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? _getMoodColor(moodValue)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      getMoodEmoji(moodValue),
                      style: TextStyle(fontSize: isSelected ? 20 : 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  moodValue.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? _getMoodColor(moodValue)
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
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

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Very Bad';
      case 2:
        return 'Bad';
      case 3:
        return 'Neutral';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Unknown';
    }
  }
}
