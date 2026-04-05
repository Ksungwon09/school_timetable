import 'package:flutter/material.dart';
import '../models.dart';
import '../api_service.dart';
import 'timetable_screen.dart';

class ClassSelectionScreen extends StatefulWidget {
  final School school;

  const ClassSelectionScreen({Key? key, required this.school}) : super(key: key);

  @override
  _ClassSelectionScreenState createState() => _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<ClassInfo> _classInfos = [];

  List<String> _grades = [];
  List<String> _departments = [];
  List<String> _classes = [];

  String? _selectedGrade;
  String? _selectedDepartment;
  String? _selectedClass;

  @override
  void initState() {
    super.initState();
    _fetchClassInfo();
  }

  void _fetchClassInfo() async {
    final infos = await _apiService.getClassInfo(
      widget.school.educationOfficeCode,
      widget.school.schoolCode,
    );

    if (mounted) {
      setState(() {
        _classInfos = infos;
        if (infos.isNotEmpty) {
          _grades = infos.map((e) => e.grade).toSet().toList()..sort();
        }
        _isLoading = false;
      });
    }
  }

  void _updateDepartments() {
    if (_selectedGrade != null) {
      _departments = _classInfos
          .where((e) => e.grade == _selectedGrade)
          .map((e) => e.departmentName)
          .toSet()
          .toList()
          ..sort();

      _selectedDepartment = null;
      _selectedClass = null;
      _classes = [];
    }
  }

  void _updateClasses() {
    if (_selectedGrade != null && _selectedDepartment != null) {
      _classes = _classInfos
          .where((e) => e.grade == _selectedGrade && e.departmentName == _selectedDepartment)
          .map((e) => e.className)
          .toSet()
          .toList()
          ..sort();

      _selectedClass = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.school.schoolName} - Select Class'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Grade'),
                    value: _selectedGrade,
                    items: _grades.map((grade) {
                      return DropdownMenuItem(
                        value: grade,
                        child: Text(grade),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGrade = value;
                        _updateDepartments();
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Department'),
                    value: _selectedDepartment,
                    items: _departments.map((dept) {
                      return DropdownMenuItem(
                        value: dept,
                        child: Text(dept),
                      );
                    }).toList(),
                    onChanged: _selectedGrade == null
                        ? null
                        : (value) {
                            setState(() {
                              _selectedDepartment = value;
                              _updateClasses();
                            });
                          },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Class'),
                    value: _selectedClass,
                    items: _classes.map((cls) {
                      return DropdownMenuItem(
                        value: cls,
                        child: Text(cls),
                      );
                    }).toList(),
                    onChanged: _selectedDepartment == null
                        ? null
                        : (value) {
                            setState(() {
                              _selectedClass = value;
                            });
                          },
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _selectedClass == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TimetableScreen(
                                  school: widget.school,
                                  grade: _selectedGrade!,
                                  department: _selectedDepartment!,
                                  className: _selectedClass!,
                                ),
                              ),
                            );
                          },
                    child: Text('View Timetable'),
                  ),
                ],
              ),
            ),
    );
  }
}
