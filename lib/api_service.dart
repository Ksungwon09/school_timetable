import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'package:intl/intl.dart';

class ApiService {
  static const String apiKey = 'b1631ef776724f03a6925ba7b6daea99';
  static const String baseUrl = 'https://open.neis.go.kr/hub';

  // 1. Search for schools
  Future<List<School>> searchSchool(String schoolName) async {
    final url = Uri.parse('$baseUrl/schoolInfo?KEY=$apiKey&Type=json&pIndex=1&pSize=100&SCHUL_NM=$schoolName');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('schoolInfo')) {
          final List<dynamic> rows = data['schoolInfo'][1]['row'];
          return rows.map((json) => School.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching school: $e');
      return [];
    }
  }

  // 2. Get Class Info (Grades, Departments, Classes)
  Future<List<ClassInfo>> getClassInfo(String eduCode, String schoolCode) async {
    final url = Uri.parse('$baseUrl/classInfo?KEY=$apiKey&Type=json&pIndex=1&pSize=1000&ATPT_OFCDC_SC_CODE=$eduCode&SD_SCHUL_CODE=$schoolCode');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('classInfo')) {
          final List<dynamic> rows = data['classInfo'][1]['row'];

          // To filter out duplicates or past years, we could use the current year:
          final currentYear = DateTime.now().year.toString();

          return rows
              .where((json) => json['AY'] == currentYear)
              .map((json) => ClassInfo.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting class info: $e');
      return [];
    }
  }

  // 3. Get Timetable
  Future<List<Timetable>> getTimetable(
      String eduCode,
      String schoolCode,
      String grade,
      String className,
      {String? department, DateTime? startDate, DateTime? endDate}) async {

    // Default to this week if dates are not provided
    final now = DateTime.now();
    final sDate = startDate ?? now.subtract(Duration(days: now.weekday - 1)); // Monday
    final eDate = endDate ?? sDate.add(Duration(days: 4)); // Friday

    final sDateStr = DateFormat('yyyyMMdd').format(sDate);
    final eDateStr = DateFormat('yyyyMMdd').format(eDate);

    String urlString = '$baseUrl/hisTimetable?KEY=$apiKey&Type=json&pIndex=1&pSize=100'
        '&ATPT_OFCDC_SC_CODE=$eduCode&SD_SCHUL_CODE=$schoolCode'
        '&GRADE=$grade&CLASS_NM=$className'
        '&TI_FROM_YMD=$sDateStr&TI_TO_YMD=$eDateStr';

    if (department != null && department != '일반계') {
        urlString += '&DDDEP_NM=$department';
    }

    final url = Uri.parse(urlString);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('hisTimetable')) {
          final List<dynamic> rows = data['hisTimetable'][1]['row'];
          return rows.map((json) => Timetable.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting timetable: $e');
      return [];
    }
  }
}
