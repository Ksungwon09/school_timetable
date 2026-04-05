class School {
  final String schoolName;
  final String schoolCode;
  final String educationOfficeCode;

  School({
    required this.schoolName,
    required this.schoolCode,
    required this.educationOfficeCode,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      schoolName: json['SCHUL_NM'] as String,
      schoolCode: json['SD_SCHUL_CODE'] as String,
      educationOfficeCode: json['ATPT_OFCDC_SC_CODE'] as String,
    );
  }
}

class ClassInfo {
  final String grade;
  final String className;
  final String departmentName;

  ClassInfo({
    required this.grade,
    required this.className,
    required this.departmentName,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      grade: json['GRADE'] as String,
      className: json['CLASS_NM'] as String,
      departmentName: json['DDDEP_NM'] as String? ?? '일반계', // Some schools might not have department
    );
  }
}

class Timetable {
  final String period;
  final String subject;
  final String date;

  Timetable({
    required this.period,
    required this.subject,
    required this.date,
  });

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      period: json['PERIO'] as String,
      subject: json['ITRT_CNTNT'] as String,
      date: json['ALL_TI_YMD'] as String,
    );
  }
}
