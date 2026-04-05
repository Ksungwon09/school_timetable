package com.example.school_timetable

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.net.URL
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import org.json.JSONObject
import kotlin.concurrent.thread

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
            views.setTextViewText(R.id.widget_content, "Loading...")
            appWidgetManager.updateAppWidget(appWidgetId, views)

            // Fetch latest data for today
            val eduCode = widgetData.getString("eduCode", null)
            val schoolCode = widgetData.getString("schoolCode", null)
            val grade = widgetData.getString("grade", null)
            val department = widgetData.getString("department", null)
            val className = widgetData.getString("className", null)

            if (eduCode != null && schoolCode != null && grade != null && className != null) {
                thread {
                    val today = SimpleDateFormat("yyyyMMdd", Locale.getDefault()).format(Date())
                    val apiKey = "b1631ef776724f03a6925ba7b6daea99"
                    var urlString = "https://open.neis.go.kr/hub/hisTimetable?KEY=$apiKey&Type=json&pIndex=1&pSize=100" +
                            "&ATPT_OFCDC_SC_CODE=$eduCode&SD_SCHUL_CODE=$schoolCode" +
                            "&GRADE=$grade&CLASS_NM=$className" +
                            "&TI_FROM_YMD=$today&TI_TO_YMD=$today"

                    if (department != null && department != "일반계") {
                        urlString += "&DDDEP_NM=$department"
                    }

                    try {
                        val response = URL(urlString).readText()
                        val jsonObject = JSONObject(response)

                        val sb = java.lang.StringBuilder()
                        val displayDate = "${today.substring(4,6)}/${today.substring(6,8)}"
                        sb.append("[$displayDate]\n")

                        if (jsonObject.has("hisTimetable")) {
                            val rows = jsonObject.getJSONArray("hisTimetable").getJSONObject(1).getJSONArray("row")

                            // Sort by period (PERIO)
                            val list = ArrayList<JSONObject>()
                            for (i in 0 until rows.length()) {
                                list.add(rows.getJSONObject(i))
                            }
                            list.sortBy { it.getString("PERIO").toIntOrNull() ?: 0 }

                            for (item in list) {
                                val period = item.getString("PERIO")
                                val subject = item.getString("ITRT_CNTNT")
                                sb.append("$period교시: $subject\n")
                            }
                        } else {
                            sb.append("오늘의 시간표가 없습니다.")
                        }

                        // Update view with fetched data
                        views.setTextViewText(R.id.widget_content, sb.toString().trim())
                        appWidgetManager.updateAppWidget(appWidgetId, views)

                    } catch (e: Exception) {
                        e.printStackTrace()
                        views.setTextViewText(R.id.widget_content, "Failed to load.")
                        appWidgetManager.updateAppWidget(appWidgetId, views)
                    }
                }
            } else {
                views.setTextViewText(R.id.widget_content, "앱을 열어 학교를 설정해주세요.")
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }
    }
}
