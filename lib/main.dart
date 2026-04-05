import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import 'screens/search_screen.dart';
import 'screens/timetable_screen.dart';
import 'models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.setAppGroupId('group.com.example.school_timetable');

  final prefs = await SharedPreferences.getInstance();
  final bool hasSavedData = prefs.containsKey('schoolCode');

  Widget initialScreen = SearchScreen();

  if (hasSavedData) {
    final school = School(
      schoolName: prefs.getString('schoolName')!,
      schoolCode: prefs.getString('schoolCode')!,
      educationOfficeCode: prefs.getString('eduCode')!,
    );
    final grade = prefs.getString('grade')!;
    final department = prefs.getString('department')!;
    final className = prefs.getString('className')!;

    initialScreen = TimetableScreen(
      school: school,
      grade: grade,
      department: department,
      className: className,
    );
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Timetable',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: initialScreen,
    );
  }
}
