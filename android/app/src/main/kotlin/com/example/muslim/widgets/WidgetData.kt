package com.example.muslim.widgets

import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

/** Data written by lib/services/home_widgets.dart through home_widget. */
data class Labels(
    val rtl: Boolean,
    val next: String,
    val verse: String,
    val dua: String,
    val name: String,
    val empty: String,
)

data class PrayerTime(val name: String, val clock: String, val at: Long)

data class PrayerInfo(val city: String, val times: List<PrayerTime>, val perDay: Int) {
    /** The prayer after [now], the one before it, and the day around it. */
    fun around(now: Long): Triple<PrayerTime, Long, List<PrayerTime>>? {
        val i = times.indexOfFirst { it.at > now }
        if (i < 0) return null
        val since = if (i > 0) times[i - 1].at else times[i].at - 6 * 3600_000L
        val start = i / perDay * perDay
        return Triple(times[i], since, times.subList(start, minOf(times.size, start + perDay)))
    }
}

data class Item(val text: String, val sub: String, val ref: String)

object WidgetData {
    /** A new item every half hour, the same on every widget of a kind. */
    const val STEP = 30 * 60_000L

    fun labels(prefs: SharedPreferences, arabicDevice: Boolean): Labels {
        val fallback = if (arabicDevice) {
            Labels(true, "الصلاة القادمة", "آية", "دعاء", "أسماء الله الحسنى", "افتح التطبيق للتحميل")
        } else {
            Labels(false, "Next prayer", "A verse", "Dua", "Names of Allah", "Open the app to load")
        }
        val m = obj(prefs, "labels") ?: return fallback
        return Labels(
            rtl = m.optBoolean("rtl", fallback.rtl),
            next = m.optString("next", fallback.next),
            verse = m.optString("verse", fallback.verse),
            dua = m.optString("dua", fallback.dua),
            name = m.optString("name", fallback.name),
            empty = m.optString("empty", fallback.empty),
        )
    }

    fun prayers(prefs: SharedPreferences): PrayerInfo? {
        val m = obj(prefs, "prayer") ?: return null
        val list = m.optJSONArray("times") ?: return null
        val times = (0 until list.length()).mapNotNull { i ->
            val t = list.optJSONObject(i) ?: return@mapNotNull null
            PrayerTime(t.optString("n"), t.optString("c"), t.optLong("t"))
        }
        if (times.isEmpty()) return null
        return PrayerInfo(m.optString("city"), times, maxOf(1, m.optInt("perDay", 6)))
    }

    fun items(prefs: SharedPreferences, key: String): List<Item> {
        val list = try {
            JSONArray(prefs.getString(key, null) ?: return emptyList())
        } catch (_: Exception) {
            return emptyList()
        }
        return (0 until list.length()).mapNotNull { i ->
            val m = list.optJSONObject(i) ?: return@mapNotNull null
            val t = m.optString("t")
            if (t.isEmpty()) null
            else Item(t, m.optString("s"), m.optString("r").ifEmpty { m.optString("n") })
        }
    }

    fun pick(items: List<Item>, now: Long): Item? =
        if (items.isEmpty()) null else items[((now / STEP) % items.size).toInt()]

    private fun obj(prefs: SharedPreferences, key: String): JSONObject? = try {
        prefs.getString(key, null)?.let { JSONObject(it) }
    } catch (_: Exception) {
        null
    }
}
