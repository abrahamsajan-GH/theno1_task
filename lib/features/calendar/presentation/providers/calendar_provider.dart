import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart' as device_cal;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarProvider extends ChangeNotifier {
  final device_cal.DeviceCalendarPlugin _deviceCalendarPlugin =
      device_cal.DeviceCalendarPlugin();

  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  List<device_cal.Calendar> _calendars = [];
  List<device_cal.Calendar> get calendars => _calendars;

  Set<String> _selectedCalendarIds = {};
  Set<String> get selectedCalendarIds => _selectedCalendarIds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  Future<void> initializeCalendar() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _hasPermission = await _requestPermissions();
    if (_hasPermission) {
      await _fetchCalendars();
      await _fetchEvents();
    } else {
      _error = 'Calendar permissions denied. Please enable them in settings.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> _requestPermissions() async {
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && (permissionsGranted.data ?? false)) {
      return true;
    }

    permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
    if (permissionsGranted.isSuccess && (permissionsGranted.data ?? false)) {
      return true;
    }

    // Fallback to permission_handler if device_calendar requests fail depending on OS.
    var status = await Permission.calendarFullAccess.request();
    return status.isGranted;
  }

  Future<void> _fetchCalendars() async {
    try {
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult.isSuccess && calendarsResult.data != null) {
        _calendars = calendarsResult.data!;
        // Select all by default if nothing selected yet
        if (_selectedCalendarIds.isEmpty) {
          _selectedCalendarIds = _calendars
              .where((c) => c.id != null)
              .map((c) => c.id!)
              .toSet();
        }
      }
    } catch (_) {}
  }

  void toggleCalendar(String id) {
    if (_selectedCalendarIds.contains(id)) {
      _selectedCalendarIds.remove(id);
    } else {
      _selectedCalendarIds.add(id);
    }
    _fetchEvents();
    notifyListeners();
  }

  Future<void> _fetchEvents() async {
    try {
      final startDate = DateTime.now().subtract(const Duration(days: 90));
      final endDate = DateTime.now().add(const Duration(days: 90));

      List<Appointment> allAppointments = [];

      for (var calendar in _calendars) {
        if (calendar.id == null || !_selectedCalendarIds.contains(calendar.id)) {
          continue;
        }
        
        final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
          calendar.id,
          device_cal.RetrieveEventsParams(
            startDate: startDate,
            endDate: endDate,
          ),
        );

        if (eventsResult.isSuccess && eventsResult.data != null) {
          for (var event in eventsResult.data!) {
            if (event.start != null && event.end != null) {
              // TimeZone support adjustments if needed (device_calendar utilizes TZDateTime)
              DateTime startTime = event.start!;
              DateTime endTime = event.end!;

              allAppointments.add(Appointment(
                startTime: startTime,
                endTime: endTime,
                subject: event.title ?? 'No Title',
                color: Color(calendar.color ?? 0xFF2563EB),
                isAllDay: event.allDay ?? false,
              ));
            }
          }
        }
      }

      _appointments = allAppointments;
    } catch (e) {
      _error = 'Failed to fetch events: ${e.toString()}';
    }
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}
