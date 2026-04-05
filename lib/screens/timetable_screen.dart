import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import '../models.dart';
import '../api_service.dart';
import 'search_screen.dart';

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
      _saveDataAndWidget(timetable);
    }
  }

  Future<void> _saveDataAndWidget(List<Timetable> timetable) async {
    // Save to SharedPreferences for app reopening
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('schoolName', widget.school.schoolName);
    await prefs.setString('schoolCode', widget.school.schoolCode);
    await prefs.setString('eduCode', widget.school.educationOfficeCode);
    await prefs.setString('grade', widget.grade);
    await prefs.setString('department', widget.department);
    await prefs.setString('className', widget.className);

    // Save parameters to widget for its own background refresh
    await HomeWidget.saveWidgetData<String>('schoolCode', widget.school.schoolCode);
    await HomeWidget.saveWidgetData<String>('eduCode', widget.school.educationOfficeCode);
    await HomeWidget.saveWidgetData<String>('grade', widget.grade);
    await HomeWidget.saveWidgetData<String>('department', widget.department);
    await HomeWidget.saveWidgetData<String>('className', widget.className);

    await HomeWidget.saveWidgetData<String>('school_info', '${widget.school.schoolName}\n${widget.grade}-${widget.className}');

    if (timetable.isNotEmpty) {
      final widgetData = timetable.map((e) => '${e.date}|${e.period}|${e.subject}').join(';;');
      await HomeWidget.saveWidgetData<String>('timetable_data', widgetData);
    }

    await HomeWidget.updateWidget(androidName: 'TimetableWidgetProvider');
  }

  void _changeClass() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SearchScreen()),
        (route) => false,
      );
    }
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
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Change Class',
            onPressed: _changeClass,
          ),
        ],
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
