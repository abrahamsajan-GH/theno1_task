import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../providers/calendar_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarProvider>().initializeCalendar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<CalendarProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(onPressed: () => provider.initializeCalendar(), child: const Text('Try Again')),
                    ],
                  ),
                ),
              );
            }

            if (!provider.hasPermission) {
              return const Center(child: Text('Permission required to fetch events.'));
            }

            if (provider.appointments.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No events found for this month.'),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Calendar',
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF4F46E5), size: 28),
                          onPressed: () => _showCalendarFilter(context, provider),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SfCalendar(
                      headerStyle: CalendarHeaderStyle(
                        backgroundColor: const Color.fromARGB(255, 217, 223, 230),
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5),
                      ),
                      allowViewNavigation: true,
                      showDatePickerButton: true,
                      view: CalendarView.month,
                      dataSource: EventDataSource(provider.appointments),
                      monthViewSettings: const MonthViewSettings(
                        appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                        showAgenda: true,
                      ),
                      initialDisplayDate: DateTime.now(),
                    ),
                  ),
                ),
                const SizedBox(height: 80), // Space for bottom nav
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCalendarFilter(BuildContext context, CalendarProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Consumer<CalendarProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Accounts & Calendars', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: provider.calendars.length,
                      itemBuilder: (context, index) {
                        final calendar = provider.calendars[index];
                        final isSelected = provider.selectedCalendarIds.contains(calendar.id);
                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(calendar.name ?? 'Unknown Calendar'),
                          subtitle: Text(calendar.accountName ?? 'Local Account'),
                          secondary: CircleAvatar(backgroundColor: Color(calendar.color ?? 0xFF4F46E5), radius: 12),
                          onChanged: (_) => provider.toggleCalendar(calendar.id!),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
