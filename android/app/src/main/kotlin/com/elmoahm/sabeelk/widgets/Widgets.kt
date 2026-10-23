package com.elmoahm.sabeelk.widgets

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
import com.elmoahm.sabeelk.MainActivity
import com.elmoahm.sabeelk.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Locale

private const val BRASS = 0xFFB0812F.toInt()
private const val CREAM = 0xFFF4EFE6.toInt()
private const val CREAM_SOFT = 0xD9F4EFE6.toInt()

private fun arabicDevice() = Locale.getDefault().language == "ar"

/** Mirrors the widget for Arabic. The launcher ignores the app locale, so set it here. */
private fun RemoteViews.direction(rtl: Boolean) {
    setInt(
        R.id.root,
        "setLayoutDirection",
        if (rtl) View.LAYOUT_DIRECTION_RTL else View.LAYOUT_DIRECTION_LTR,
    )
}

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
        views.direction(labels.rtl)
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
            views.direction(labels.rtl)
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

class HadithWidget : ItemWidget("hadiths", "hadith", false) {
    override fun title(labels: Labels) = labels.hadith
}

/** Today's Hijri date; turns over at local midnight. */
class HijriWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val now = System.currentTimeMillis()
        val labels = WidgetData.labels(widgetData, arabicDevice())
        val day = WidgetData.hijri(widgetData, now)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_hijri)
            views.direction(labels.rtl)
            views.setOnClickPendingIntent(R.id.root, open(context, "hijri"))
            views.setTextViewText(R.id.caption, day?.civil ?: labels.hijri)
            views.setTextViewText(R.id.text, day?.hijri ?: labels.empty)
            views.setTextViewText(R.id.sub, day?.next ?: "")
            views.setViewVisibility(R.id.sub, if (day?.next.isNullOrEmpty()) View.GONE else View.VISIBLE)
            appWidgetManager.updateAppWidget(id, views)
        }
        val midnight = java.util.Calendar.getInstance().apply {
            add(java.util.Calendar.DAY_OF_YEAR, 1)
            set(java.util.Calendar.HOUR_OF_DAY, 0)
            set(java.util.Calendar.MINUTE, 0)
            set(java.util.Calendar.SECOND, 5)
        }.timeInMillis
        wakeAt(context, javaClass, midnight)
    }
}

/** A tap counter: 33 each of SubhanAllah, Alhamdulillah and Allahu Akbar. */
class TasbihWidget : HomeWidgetProvider() {
    override fun onReceive(context: Context, intent: Intent) {
        val prefs = HomeWidgetPlugin.getData(context)
        when (intent.action) {
            TAP -> prefs.edit().putLong(WidgetData.TASBIH_COUNT, prefs.getLong(WidgetData.TASBIH_COUNT, 0) + 1).apply()
            RESET -> prefs.edit().putLong(WidgetData.TASBIH_COUNT, 0).apply()
            else -> return super.onReceive(context, intent)
        }
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, javaClass))
        onUpdate(context, manager, ids, prefs)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val labels = WidgetData.labels(widgetData, arabicDevice())
        val count = widgetData.getLong(WidgetData.TASBIH_COUNT, 0)
        val phrase = labels.phrases[((count / 33) % labels.phrases.size).toInt()]
        val shown = if (labels.rtl) toArabicDigits(count.toString()) else count.toString()
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_tasbih)
            views.direction(labels.rtl)
            views.setOnClickPendingIntent(R.id.root, broadcast(context, TAP))
            views.setOnClickPendingIntent(R.id.reset, broadcast(context, RESET))
            views.setTextViewText(R.id.caption, phrase)
            views.setTextViewText(R.id.text, shown)
            views.setTextViewText(R.id.reset, labels.reset)
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun broadcast(context: Context, action: String): PendingIntent =
        PendingIntent.getBroadcast(
            context,
            action.hashCode(),
            Intent(context, TasbihWidget::class.java).setAction(action),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

    private fun toArabicDigits(s: String) =
        s.map { if (it in '0'..'9') '٠' + (it - '0') else it }.joinToString("")

    companion object {
        const val TAP = "com.elmoahm.sabeelk.TASBIH_TAP"
        const val RESET = "com.elmoahm.sabeelk.TASBIH_RESET"
    }
}
