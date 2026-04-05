# Agent Instructions

This project is an Android application that queries the NEIS Open API to display high school class schedules. It features a home screen widget to show the timetable.

### Goal
- Create an Android APK file for the application.
- Integrate with the NEIS Open API using the provided API key: `b1631ef776724f03a6925ba7b6daea99`.

### Input and Output Conventions
- **School Search**: The app will allow users to search for a school by name. If multiple results appear, the user can select one. If no results are found, the user will be prompted to re-enter the name.
- **Class Selection**: After selecting a school, the app will fetch the available departments, grades, and classes, allowing the user to select them from a list instead of manually entering them.
- **Timetable Display**: The app will display the class schedule based on the user's selection.
- **Widget**: A home screen widget will display the timetable. The widget will support various sizes, and course names (which can sometimes exceed 10 characters) will not be cut off.
