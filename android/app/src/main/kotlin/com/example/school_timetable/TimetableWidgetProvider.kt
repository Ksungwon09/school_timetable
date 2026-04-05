package com.example.school_timetable

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class TimetableWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            val schoolInfo = widgetData.getString("school_info", "Timetable")
            views.setTextViewText(R.id.widget_title, schoolInfo)

            val timetableStr = widgetData.getString("timetable_data", null)
            val displayText = if (timetableStr != null) {
                // Parse "date|period|subject;;date|period|subject"
                val items = timetableStr.split(";;")
                val sb = java.lang.StringBuilder()

                // For simplicity in the widget, show a list
                var currentDate = ""
                for (item in items) {
                    val parts = item.split("|")
                    if (parts.size >= 3) {
                        val date = parts[0]
                        val period = parts[1]
                        val subject = parts[2]

                        if (date != currentDate) {
                            if (sb.isNotEmpty()) sb.append("\n")
                            // Format date for better display (e.g. 20231012 -> 10/12)
                            val displayDate = if (date.length == 8) "${date.substring(4,6)}/${date.substring(6,8)}" else date
                            sb.append("[$displayDate]\n")
                            currentDate = date
                        }
                        sb.append("$period: $subject\n")
                    }
                }
                sb.toString().trim()
            } else {
                "Open the app to load timetable."
            }

            views.setTextViewText(R.id.widget_content, displayText)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
