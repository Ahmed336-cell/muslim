package com.example.muslim.widgets

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import com.example.muslim.MainActivity
import com.example.muslim.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Locale

private const val BRASS = 0xFFB0812F.toInt()
private const val CREAM = 0xFFF4EFE6.toInt()
private const val CREAM_SOFT = 0xD9F4EFE6.toInt()

private fun arabicDevice() = Locale.getDefault().language == "ar"

private fun open(context: Context, host: String): PendingIntent =
    HomeWidgetLaunchIntent.getActivity(
        context,
        MainActivity::class.java,
        Uri.parse("muslim://$host?homeWidget"),
    )

/** Redraws [provider]'s widgets at [at], so they move on while the app is closed. */
private fun wakeAt(context: Context, provider: Class<*>, at: Long) {
    val manager = AppWidgetManager.getInstance(context)
    val ids = manager.getAppWidgetIds(ComponentName(context, provider))
    if (ids.isEmpty()) return
    val intent = Intent(context, provider)
        .setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
        .putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
    val pending = PendingIntent.getBroadcast(
        context,
        provider.name.hashCode(),
        intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
    val alarms = context.getSystemService(AlarmManager::class.java) ?: return
    val exact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarms.canScheduleExactAlarms()
    try {
        if (exact) {
            alarms.setExactAndAllowWhileIdle(AlarmManager.RTC, at, pending)
        } else {
            alarms.setAndAllowWhileIdle(AlarmManager.RTC, at, pending)
        }
    } catch (_: SecurityException) {
        alarms.set(AlarmManager.RTC, at, pending)
    }
}

class PrayerWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val now = System.currentTimeMillis()
        val info = WidgetData.prayers(widgetData)
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, build(context, appWidgetManager, id, widgetData, now))
        }
        info?.around(now)?.let { wakeAt(context, javaClass, it.first.at + 1000) }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        appWidgetManager.updateAppWidget(
            appWidgetId,
            build(context, appWidgetManager, appWidgetId, prefs, System.currentTimeMillis()),
        )
    }

    private fun build(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
        prefs: SharedPreferences,
        now: Long,
    ): RemoteViews {
        val labels = WidgetData.labels(prefs, arabicDevice())
        val views = RemoteViews(context.packageName, R.layout.widget_prayer)
        views.setOnClickPendingIntent(R.id.root, open(context, "prayer"))
        views.setTextViewText(R.id.caption, labels.next)
        val around = WidgetData.prayers(prefs)?.let { info -> info.around(now)?.let { info to it } }
        if (around == null) {
            views.setTextViewText(R.id.name, labels.empty)
            views.setViewVisibility(R.id.countdown, View.GONE)
            views.setViewVisibility(R.id.list, View.GONE)
            return views
        }
        val (info, a) = around
        val (next, _, day) = a
        views.setTextViewText(R.id.name, next.name)
        views.setTextViewText(R.id.time, next.clock)
        views.setTextViewText(R.id.city, info.city)
        views.setViewVisibility(R.id.countdown, View.VISIBLE)
        views.setChronometer(
            R.id.countdown,
            SystemClock.elapsedRealtime() + (next.at - now),
            null,
            true,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            views.setChronometerCountDown(R.id.countdown, true)
        }

        val width = manager.getAppWidgetOptions(id)
            .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
        val wide = width >= 230
        views.setViewVisibility(R.id.list, if (wide) View.VISIBLE else View.GONE)
        if (wide) {
            ROWS.forEachIndexed { i, (nameId, timeId) ->
                val p = day.getOrNull(i)
                val row = ROW_IDS[i]
                views.setViewVisibility(row, if (p == null) View.GONE else View.VISIBLE)
                if (p != null) {
                    val color = if (p == next) BRASS else CREAM_SOFT
                    views.setTextViewText(nameId, p.name)
                    views.setTextViewText(timeId, p.clock)
                    views.setTextColor(nameId, color)
                    views.setTextColor(timeId, color)
                }
            }
        }
        return views
    }

    companion object {
        private val ROW_IDS = intArrayOf(R.id.row0, R.id.row1, R.id.row2, R.id.row3, R.id.row4, R.id.row5)
        private val ROWS = listOf(
            R.id.row0_name to R.id.row0_time,
            R.id.row1_name to R.id.row1_time,
            R.id.row2_name to R.id.row2_time,
            R.id.row3_name to R.id.row3_time,
            R.id.row4_name to R.id.row4_time,
            R.id.row5_name to R.id.row5_time,
        )
    }
}

/** A widget that shows a new ayah, dua or name every half hour. */
abstract class ItemWidget(
    private val key: String,
    private val host: String,
    private val isName: Boolean,
) : HomeWidgetProvider() {
    abstract fun title(labels: Labels): String

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val now = System.currentTimeMillis()
        val labels = WidgetData.labels(widgetData, arabicDevice())
        val item = WidgetData.pick(WidgetData.items(widgetData, key), now)
        for (id in appWidgetIds) {
            val views = RemoteViews(
                context.packageName,
                if (isName) R.layout.widget_name else R.layout.widget_item,
            )
            views.setOnClickPendingIntent(R.id.root, open(context, host))
            views.setTextViewText(R.id.caption, title(labels))
            views.setTextViewText(R.id.text, item?.text ?: labels.empty)
            views.setTextViewText(R.id.sub, item?.sub ?: "")
            views.setViewVisibility(R.id.sub, if (item?.sub.isNullOrEmpty()) View.GONE else View.VISIBLE)
            if (!isName) {
                views.setTextViewText(R.id.ref, item?.ref ?: "")
            }
            appWidgetManager.updateAppWidget(id, views)
        }
        wakeAt(context, javaClass, (now / WidgetData.STEP + 1) * WidgetData.STEP + 1000)
    }
}

class AyahWidget : ItemWidget("ayahs", "ayah", false) {
    override fun title(labels: Labels) = labels.verse
}

class DuaWidget : ItemWidget("duas", "dua", false) {
    override fun title(labels: Labels) = labels.dua
}

class NameWidget : ItemWidget("names", "name", true) {
    override fun title(labels: Labels) = labels.name
}
