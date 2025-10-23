import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_dashboard/helpers/app_greeting.dart';
import 'package:health_dashboard/helpers/theming/theme_provider.dart';
import 'package:health_dashboard/presentations/dashboard/data/dashboard_provider.dart';
import 'package:health_dashboard/presentations/dashboard/presentation/chart_screen.dart';
import 'package:health_dashboard/presentations/dashboard/presentation/widgets/range_control.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theming, _) {
        return Scaffold(
          backgroundColor: theming.isDarkMode
              ? Colors.grey[900]
              : Colors.grey[100],
          body: SafeArea(
            child: Consumer<DashboardState>(
              builder: (context, state, _) {
                return Column(
                  children: [
                    Selector(
                      selector: (_, ThemeProvider themeProvider) =>
                          themeProvider.isDarkMode,

                      builder: (context, darkMode, child) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: darkMode ? Colors.black : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dashboard',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,

                                            color: darkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              AppGreeting().getGreeting(),
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                color: darkMode
                                                    ? Colors.grey[600]
                                                    : Colors.grey[800],
                                              ),
                                            ),
                                            Text(
                                              ' Kingsley Doe',
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: darkMode
                                                    ? Colors.grey[600]
                                                    : Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Provider.of<ThemeProvider>(
                                        context,
                                        listen: false,
                                      ).toggleTheme();
                                    },
                                    icon: darkMode
                                        ? const Icon(
                                            Icons.light_mode,
                                            color: Colors.yellow,
                                          )
                                        : const Icon(Icons.dark_mode),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    Expanded(
                      child: _buildBody(
                        context,
                        state,
                        Provider.of<ThemeProvider>(context),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    DashboardState state,
    ThemeProvider theme,
  ) {
    if (state.isLoading) {
      return _buildLoadingState(context, theme.isDarkMode);
    }

    if (state.error != null) {
      return _buildErrorState(context, state);
    }

    if (state.biometrics == null || state.biometrics!.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildChartsView(context, state);
  }

  Widget _buildLoadingState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.white : Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading biometrics...',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Simulating network latency',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(height: 100),
            _buildLoadingSkeleton(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 20,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 500,
              width: 800,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.show_chart,
                  size: 48,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, DashboardState state) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Data',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => state.retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No Data Available',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There are no biometric records to display',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsView(BuildContext context, DashboardState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          RangeControls(
            selectedRange: state.selectedRange,
            onRangeChanged: (range) => state.setTimeRange(range),
          ),
          const SizedBox(height: 16),
          _buildLargeDatasetToggle(
            context,
            state,
            Provider.of<ThemeProvider>(context),
          ),
          const SizedBox(height: 20),
          Center(
            child: SynchronizedBiometricCharts(
              data: state.biometrics!,
              journals: state.journals ?? [],
              timeRange: state.selectedRange,
            ),
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }

  Widget _buildLargeDatasetToggle(
    BuildContext context,
    DashboardState state,
    ThemeProvider themeProvider,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 300,

        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? Colors.grey[850]
              : Colors.blueAccent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: state.useLargeDataset
                ? const Color.fromARGB(255, 180, 204, 245)
                : (themeProvider.isDarkMode
                      ? Colors.grey[700]!
                      : Colors.grey[300]!),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.speed,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Large Dataset Mode',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Simulate 10K+ data points',
                    style: GoogleFonts.montserrat(
                      color: themeProvider.isDarkMode
                          ? Colors.white60
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: state.useLargeDataset,
              onChanged: (_) => state.toggleLargeDataset(),
              activeThumbColor: Colors.blueAccent,
              inactiveThumbColor: themeProvider.isDarkMode
                  ? Colors.grey
                  : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
