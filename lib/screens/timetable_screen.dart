import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../models.dart';
import '../api_service.dart';

class TimetableScreen extends StatefulWidget {
  final School school;
  final String grade;
  final String department;
  final String className;

  const TimetableScreen({
    Key? key,
    required this.school,
    required this.grade,
    required this.department,
    required this.className,
  }) : super(key: key);

  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Timetable> _timetable = [];

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  void _fetchTimetable() async {
    final timetable = await _apiService.getTimetable(
      widget.school.educationOfficeCode,
      widget.school.schoolCode,
      widget.grade,
      widget.className,
      department: widget.department,
    );

    if (mounted) {
      setState(() {
        _timetable = timetable;
        _isLoading = false;
      });
      _saveToWidget(timetable);
    }
  }

  Future<void> _saveToWidget(List<Timetable> timetable) async {
    // Group timetable by date, then period to format a summary string or JSON for the widget
    if (timetable.isEmpty) return;

    // Simple serialization for the widget
    final widgetData = timetable.map((e) => '${e.date}|${e.period}|${e.subject}').join(';;');

    await HomeWidget.saveWidgetData<String>('timetable_data', widgetData);
    await HomeWidget.saveWidgetData<String>('school_info', '${widget.school.schoolName} ${widget.grade}-${widget.className}');
    await HomeWidget.updateWidget(androidName: 'TimetableWidgetProvider');
  }

  @override
  Widget build(BuildContext context) {
    // Group by date
    final Map<String, List<Timetable>> groupedTimetable = {};
    for (var t in _timetable) {
      if (!groupedTimetable.containsKey(t.date)) {
        groupedTimetable[t.date] = [];
      }
      groupedTimetable[t.date]!.add(t);
    }

    final dates = groupedTimetable.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.school.schoolName} Timetable'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _timetable.isEmpty
              ? Center(child: Text('No timetable data available.'))
              : ListView.builder(
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final dailySchedule = groupedTimetable[date]!..sort((a, b) => a.period.compareTo(b.period));

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: $date',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            ...dailySchedule.map((t) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text('Period ${t.period}', style: TextStyle(fontWeight: FontWeight.w500)),
                                      ),
                                      Expanded(
                                        child: Text(t.subject, style: TextStyle(fontSize: 16)),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
