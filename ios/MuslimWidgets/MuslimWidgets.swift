import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

// Data is written by lib/services/home_widgets.dart through home_widget.
private let appGroup = "group.com.elmoahm.sabeelk"

private enum Palette {
  static let green = Color(red: 0x1E / 255, green: 0x4D / 255, blue: 0x3A / 255)
  static let paper = Color(red: 0xF4 / 255, green: 0xEF / 255, blue: 0xE6 / 255)
  static let ink = Color(red: 0x1F / 255, green: 0x2A / 255, blue: 0x24 / 255)
  static let inkSoft = Color(red: 0x5B / 255, green: 0x66 / 255, blue: 0x60 / 255)
  static let brass = Color(red: 0xB0 / 255, green: 0x81 / 255, blue: 0x2F / 255)
  static let cream = Color(red: 0xF4 / 255, green: 0xEF / 255, blue: 0xE6 / 255)
}

// MARK: - Shared storage

private enum Store {
  static func json(_ key: String) -> Any? {
    guard let text = UserDefaults(suiteName: appGroup)?.string(forKey: key),
      let data = text.data(using: .utf8)
    else { return nil }
    return try? JSONSerialization.jsonObject(with: data)
  }

  static var labels: Labels {
    let arabic = Locale.preferredLanguages.first?.hasPrefix("ar") ?? false
    var l = arabic ? Labels.arabic : Labels.english
    if let m = json("labels") as? [String: Any] {
      l.rtl = m["rtl"] as? Bool ?? l.rtl
      l.next = m["next"] as? String ?? l.next
      l.verse = m["verse"] as? String ?? l.verse
      l.dua = m["dua"] as? String ?? l.dua
      l.name = m["name"] as? String ?? l.name
      l.empty = m["empty"] as? String ?? l.empty
      l.hadith = m["hadith"] as? String ?? l.hadith
      l.hijri = m["hijri"] as? String ?? l.hijri
      l.tasbih = m["tasbih"] as? String ?? l.tasbih
      l.reset = m["reset"] as? String ?? l.reset
      if let p = m["phrases"] as? [String], !p.isEmpty { l.phrases = p }
    }
    return l
  }

  /// One entry per day, written ahead by the app.
  static var hijriDays: [HijriDay] {
    guard let list = json("hijri") as? [[String: Any]] else { return [] }
    return list.compactMap { m in
      guard let ms = m["d"] as? Double, let t = m["t"] as? String else { return nil }
      return HijriDay(
        start: Date(timeIntervalSince1970: ms / 1000), hijri: t,
        civil: m["s"] as? String ?? "", next: m["r"] as? String ?? "")
    }
  }

  static let tasbihKey = "tasbih_count"

  static var tasbih: Int {
    get { UserDefaults(suiteName: appGroup)?.integer(forKey: tasbihKey) ?? 0 }
    set { UserDefaults(suiteName: appGroup)?.set(newValue, forKey: tasbihKey) }
  }

  static var prayers: PrayerInfo? {
    guard let m = json("prayer") as? [String: Any],
      let times = m["times"] as? [[String: Any]]
    else { return nil }
    let list = times.compactMap { t -> PrayerTime? in
      guard let n = t["n"] as? String, let c = t["c"] as? String,
        let ms = t["t"] as? Double
      else { return nil }
      return PrayerTime(name: n, clock: c, at: Date(timeIntervalSince1970: ms / 1000))
    }
    return list.isEmpty
      ? nil
      : PrayerInfo(
        city: m["city"] as? String ?? "", times: list,
        perDay: max(1, m["perDay"] as? Int ?? 6))
  }

  static func items(_ key: String) -> [Item] {
    guard let list = json(key) as? [[String: String]] else { return [] }
    return list.compactMap { m in
      guard let t = m["t"], !t.isEmpty else { return nil }
      return Item(text: t, sub: m["s"] ?? "", ref: m["r"] ?? m["n"] ?? "")
    }
  }
}

struct Labels {
  var rtl: Bool
  var next: String
  var verse: String
  var dua: String
  var name: String
  var empty: String
  var hadith: String
  var hijri: String
  var tasbih: String
  var phrases: [String]
  var reset: String

  static let english = Labels(
    rtl: false, next: "Next prayer", verse: "A verse", dua: "Dua",
    name: "Names of Allah", empty: "Open the app to load", hadith: "Hadith",
    hijri: "Hijri date", tasbih: "Tasbih",
    phrases: ["SubhanAllah", "Alhamdulillah", "Allahu Akbar"], reset: "Reset")
  static let arabic = Labels(
    rtl: true, next: "الصلاة القادمة", verse: "آية", dua: "دعاء",
    name: "أسماء الله الحسنى", empty: "افتح التطبيق للتحميل", hadith: "حديث",
    hijri: "التاريخ الهجري", tasbih: "المسبحة",
    phrases: ["سبحان الله", "الحمد لله", "الله أكبر"], reset: "تصفير")
}

struct HijriDay {
  let start: Date
  let hijri: String
  let civil: String
  let next: String
}

struct PrayerTime: Hashable {
  let name: String
  let clock: String
  let at: Date
}

struct PrayerInfo {
  let city: String
  let times: [PrayerTime]
  var perDay = 6

  /// The prayer after [date], the one before it, and the day around it.
  func around(_ date: Date) -> (next: PrayerTime, since: Date, day: [PrayerTime])? {
    guard let i = times.firstIndex(where: { $0.at > date }) else { return nil }
    let since = i > 0 ? times[i - 1].at : times[i].at.addingTimeInterval(-6 * 3600)
    let start = i / perDay * perDay
    let day = Array(times[start..<min(times.count, start + perDay)])
    return (times[i], since, day)
  }
}

struct Item: Hashable {
  let text: String
  let sub: String
  let ref: String
}

// MARK: - Look

extension View {
  @ViewBuilder
  fileprivate func widgetBackground(_ color: Color, family: WidgetFamily) -> some View {
    let accessory = [.accessoryCircular, .accessoryRectangular, .accessoryInline]
      .contains(family)
    if #available(iOSApplicationExtension 17.0, *) {
      containerBackground(for: .widget) { accessory ? Color.clear : color }
    } else {
      background(accessory ? Color.clear : color)
    }
  }

  /// App language, not the phone language.
  @ViewBuilder
  fileprivate func direction(_ labels: Labels) -> some View {
    widgetLocale(labels.rtl)
  }

  fileprivate func widgetLocale(_ rtl: Bool) -> some View {
    environment(\.layoutDirection, rtl ? .rightToLeft : .leftToRight)
  }
}

/// Timer text under an Arabic numbering locale prints 9.0:31.0:27.0.
private let clockLocale = Locale(identifier: "en_US_POSIX")

private func link(_ host: String) -> URL { URL(string: "muslim://\(host)?homeWidget")! }

/// Letter spacing would pull Arabic letters apart, so only Latin is spaced.
private func caption(_ text: String, rtl: Bool) -> some View {
  Text(rtl ? text : text.uppercased())
    .font(.system(size: rtl ? 11 : 10, weight: .semibold))
    .tracking(rtl ? 0 : 1)
    .foregroundStyle(Palette.brass)
}

// MARK: - Prayer

struct PrayerEntry: TimelineEntry {
  let date: Date
  let info: PrayerInfo?
  let labels: Labels
}

struct PrayerProvider: TimelineProvider {
  func placeholder(in context: Context) -> PrayerEntry {
    PrayerEntry(date: .now, info: .sample, labels: .english)
  }

  func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
    let info = Store.prayers ?? (context.isPreview ? .sample : nil)
    completion(PrayerEntry(date: .now, info: info, labels: Store.labels))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
    let labels = Store.labels
    let info = Store.prayers
    let now = Date()
    var entries = [PrayerEntry(date: now, info: info, labels: labels)]
    // A new entry as each prayer comes in, so the widget moves on by itself.
    for t in info?.times ?? [] where t.at > now && entries.count < 24 {
      entries.append(PrayerEntry(date: t.at, info: info, labels: labels))
    }
    completion(Timeline(entries: entries, policy: .atEnd))
  }
}

extension PrayerInfo {
  static var sample: PrayerInfo {
    let now = Date()
    let names = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
    return PrayerInfo(
      city: "Makkah",
      times: names.enumerated().map { i, n in
        PrayerTime(name: n, clock: "\(4 + i * 3):30", at: now.addingTimeInterval(Double(i) * 9000 + 3000))
      })
  }
}

struct PrayerView: View {
  @Environment(\.widgetFamily) var family
  let entry: PrayerEntry

  var body: some View {
    content
      .direction(entry.labels)
      .widgetBackground(Palette.green, family: family)
      .widgetURL(link("prayer"))
  }

  @ViewBuilder var content: some View {
    if let info = entry.info, let now = info.around(entry.date) {
      switch family {
      case .accessoryInline:
        Text("\(now.next.name) \(now.next.clock)")
      case .accessoryCircular:
        ZStack {
          AccessoryWidgetBackground()
          ProgressView(timerInterval: now.since...now.next.at, countsDown: false) {
            EmptyView()
          } currentValueLabel: {
            EmptyView()
          }
          .progressViewStyle(.circular)
          VStack(spacing: 0) {
            Text(now.next.name).font(.system(size: 12, weight: .semibold))
            Text(now.next.clock).font(.system(size: 9))
          }
          .lineLimit(1).minimumScaleFactor(0.5).padding(6)
        }
      case .accessoryRectangular:
        VStack(alignment: .leading, spacing: 1) {
          Text(entry.labels.next).font(.caption2).foregroundStyle(.secondary)
          Text("\(now.next.name) · \(now.next.clock)").font(.headline).lineLimit(1)
          countdown(now.next.at).font(.body.monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      case .systemMedium, .systemLarge:
        HStack(spacing: 14) {
          summary(now.next, city: info.city)
          VStack(spacing: 3) {
            ForEach(now.day, id: \.self) { p in
              HStack {
                Text(p.name).lineLimit(1)
                Spacer(minLength: 4)
                Text(p.clock).monospacedDigit()
              }
              .font(.system(size: 12, weight: p == now.next ? .bold : .regular))
              .foregroundStyle(p == now.next ? Palette.brass : Palette.cream.opacity(0.85))
            }
          }
          .frame(maxWidth: 130)
        }
      default:
        summary(now.next, city: info.city)
      }
    } else {
      empty
    }
  }

  func countdown(_ at: Date) -> some View {
    Text(timerInterval: entry.date...max(at, entry.date), countsDown: true)
      .environment(\.locale, clockLocale)
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, alignment: .leading)
  }

  func summary(_ next: PrayerTime, city: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      caption(entry.labels.next, rtl: entry.labels.rtl)
      Text(next.name).font(.system(size: 24, weight: .semibold, design: .serif))
        .foregroundStyle(Palette.cream).lineLimit(1).minimumScaleFactor(0.6)
      Text(next.clock).font(.system(size: 14, weight: .medium))
        .foregroundStyle(Palette.cream.opacity(0.8))
      Spacer(minLength: 0)
      countdown(next.at)
        .font(.system(size: 20, weight: .semibold).monospacedDigit())
        .foregroundStyle(Palette.cream)
      if !city.isEmpty {
        Text(city).font(.system(size: 10)).foregroundStyle(Palette.cream.opacity(0.6))
          .lineLimit(1)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder var empty: some View {
    if family == .accessoryInline || family == .accessoryCircular {
      Image(systemName: "moon.stars")
    } else {
      Text(entry.labels.empty).font(.footnote)
        .foregroundStyle(family == .accessoryRectangular ? Color.primary : Palette.cream)
    }
  }
}

struct PrayerWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "PrayerWidget", provider: PrayerProvider()) {
      PrayerView(entry: $0)
    }
    .configurationDisplayName(Store.labels.next)
    .description(Store.labels.rtl ? "موعد الصلاة القادمة والوقت المتبقي" : "Next prayer time and the time left")
    .supportedFamilies([
      .systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline,
    ])
  }
}

// MARK: - Rotating content

enum Pool: String {
  case ayahs, duas, names, hadiths

  var host: String {
    switch self {
    case .ayahs: "ayah"
    case .duas: "dua"
    case .names: "name"
    case .hadiths: "hadith"
    }
  }

  func title(_ l: Labels) -> String {
    switch self {
    case .ayahs: l.verse
    case .duas: l.dua
    case .names: l.name
    case .hadiths: l.hadith
    }
  }

  var sample: Item {
    switch self {
    case .ayahs: Item(text: "فإن مع العسر يسرا", sub: "", ref: "Ash-Sharh · 5")
    case .duas: Item(text: "رب زدني علما", sub: "My Lord, increase me in knowledge", ref: "")
    case .names: Item(text: "الرحمن", sub: "The Most Merciful", ref: "Ar-Rahman")
    case .hadiths:
      Item(
        text: "الدين النصيحة", sub: "The religion is sincerity.",
        ref: "Nawawi's Forty · 7")
    }
  }
}

struct ItemEntry: TimelineEntry {
  let date: Date
  let item: Item?
  let labels: Labels
}

struct ItemProvider: TimelineProvider {
  let pool: Pool

  /// A new item every half hour, the same on every widget of a kind.
  static let step: TimeInterval = 1800

  func placeholder(in context: Context) -> ItemEntry {
    ItemEntry(date: .now, item: pool.sample, labels: .english)
  }

  func getSnapshot(in context: Context, completion: @escaping (ItemEntry) -> Void) {
    let items = Store.items(pool.rawValue)
    completion(ItemEntry(date: .now, item: pick(items, at: .now) ?? pool.sample, labels: Store.labels))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<ItemEntry>) -> Void) {
    let items = Store.items(pool.rawValue)
    let labels = Store.labels
    let start = floor(Date().timeIntervalSince1970 / Self.step) * Self.step
    let entries = (0..<24).map { i in
      let date = Date(timeIntervalSince1970: start + Double(i) * Self.step)
      return ItemEntry(date: date, item: pick(items, at: date), labels: labels)
    }
    completion(Timeline(entries: entries, policy: .atEnd))
  }

  func pick(_ items: [Item], at date: Date) -> Item? {
    guard !items.isEmpty else { return nil }
    return items[Int(date.timeIntervalSince1970 / Self.step) % items.count]
  }
}

struct ItemView: View {
  @Environment(\.widgetFamily) var family
  let pool: Pool
  let entry: ItemEntry

  var body: some View {
    content
      .direction(entry.labels)
      .widgetBackground(Palette.paper, family: family)
      .widgetURL(link(pool.host))
  }

  var arabicSize: CGFloat {
    switch family {
    case .systemSmall: pool == .names ? 34 : 16
    case .systemLarge: pool == .names ? 56 : 26
    default: pool == .names ? 40 : 20
    }
  }

  @ViewBuilder var content: some View {
    if let item = entry.item {
      switch family {
      case .accessoryInline:
        Text(item.text)
      case .accessoryRectangular:
        VStack(alignment: .leading, spacing: 1) {
          Text(item.text).font(.system(size: pool == .names ? 20 : 14, weight: .semibold))
            .lineLimit(pool == .names ? 1 : 3).minimumScaleFactor(0.7)
            .environment(\.layoutDirection, .rightToLeft)
          if pool == .names, !item.sub.isEmpty {
            Text(item.sub).font(.caption2).lineLimit(1)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      default:
        card(item)
      }
    } else {
      Text(entry.labels.empty).font(.footnote).foregroundStyle(Palette.inkSoft)
    }
  }

  func card(_ item: Item) -> some View {
    VStack(alignment: pool == .names ? .center : .leading, spacing: 6) {
      caption(pool.title(entry.labels), rtl: entry.labels.rtl)
        .frame(maxWidth: .infinity, alignment: pool == .names ? .center : .leading)
      Spacer(minLength: 0)
      Text(item.text)
        .font(.system(size: arabicSize, weight: pool == .names ? .bold : .medium))
        .foregroundStyle(pool == .names ? Palette.green : Palette.ink)
        .multilineTextAlignment(pool == .names ? .center : .leading)
        .lineSpacing(4)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity, alignment: pool == .names ? .center : .leading)
        .environment(\.layoutDirection, .rightToLeft)
      if !item.sub.isEmpty && family != .systemSmall || pool == .names {
        Text(item.sub)
          .font(.system(size: 12))
          .foregroundStyle(Palette.inkSoft)
          .multilineTextAlignment(pool == .names ? .center : .leading)
          .lineLimit(family == .systemLarge ? 6 : 2)
          .minimumScaleFactor(0.8)
      }
      Spacer(minLength: 0)
      if !item.ref.isEmpty && pool != .names {
        Text(item.ref).font(.system(size: 11, weight: .medium))
          .foregroundStyle(Palette.brass).lineLimit(1)
      }
    }
  }
}

private func itemWidget(_ pool: Pool, kind: String, families: [WidgetFamily]) -> some WidgetConfiguration {
  StaticConfiguration(kind: kind, provider: ItemProvider(pool: pool)) {
    ItemView(pool: pool, entry: $0)
  }
  .configurationDisplayName(pool.title(Store.labels))
  .description(Store.labels.rtl ? "يتغير كل نصف ساعة" : "Changes every half hour")
  .supportedFamilies(families)
}

struct AyahWidget: Widget {
  var body: some WidgetConfiguration {
    itemWidget(.ayahs, kind: "AyahWidget", families: [
      .systemSmall, .systemMedium, .systemLarge, .accessoryRectangular,
    ])
  }
}

struct DuaWidget: Widget {
  var body: some WidgetConfiguration {
    itemWidget(.duas, kind: "DuaWidget", families: [
      .systemSmall, .systemMedium, .systemLarge, .accessoryRectangular,
    ])
  }
}

struct NameWidget: Widget {
  var body: some WidgetConfiguration {
    itemWidget(.names, kind: "NameWidget", families: [
      .systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline,
    ])
  }
}

struct HadithWidget: Widget {
  var body: some WidgetConfiguration {
    itemWidget(.hadiths, kind: "HadithWidget", families: [
      .systemSmall, .systemMedium, .systemLarge, .accessoryRectangular,
    ])
  }
}

// MARK: - Hijri date

struct HijriEntry: TimelineEntry {
  let date: Date
  let day: HijriDay?
  let labels: Labels
}

struct HijriProvider: TimelineProvider {
  static let sample = HijriDay(
    start: .now, hijri: "12 Rabi al-Akhir 1448 AH", civil: "Monday 12 October",
    next: "Ramadan in 140 days")

  func placeholder(in context: Context) -> HijriEntry {
    HijriEntry(date: .now, day: Self.sample, labels: .english)
  }

  func getSnapshot(in context: Context, completion: @escaping (HijriEntry) -> Void) {
    let day = Store.hijriDays.last { $0.start <= .now } ?? (context.isPreview ? Self.sample : nil)
    completion(HijriEntry(date: .now, day: day, labels: Store.labels))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<HijriEntry>) -> Void) {
    let labels = Store.labels
    let days = Store.hijriDays
    let now = Date()
    var entries = [HijriEntry(date: now, day: days.last { $0.start <= now }, labels: labels)]
    for d in days where d.start > now {
      entries.append(HijriEntry(date: d.start, day: d, labels: labels))
    }
    completion(Timeline(entries: entries, policy: .atEnd))
  }
}

struct HijriView: View {
  @Environment(\.widgetFamily) var family
  let entry: HijriEntry

  var body: some View {
    content
      .direction(entry.labels)
      .widgetBackground(Palette.green, family: family)
      .widgetURL(link("hijri"))
  }

  @ViewBuilder var content: some View {
    if let day = entry.day {
      switch family {
      case .accessoryInline:
        Text(day.hijri)
      case .accessoryCircular:
        ZStack {
          AccessoryWidgetBackground()
          Text(day.hijri.split(separator: " ").first.map(String.init) ?? "")
            .font(.system(size: 22, weight: .semibold))
        }
      case .accessoryRectangular:
        VStack(alignment: .leading, spacing: 1) {
          Text(day.civil).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
          Text(day.hijri).font(.headline).lineLimit(1).minimumScaleFactor(0.7)
          if !day.next.isEmpty { Text(day.next).font(.caption2).lineLimit(1) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      default:
        VStack(spacing: 6) {
          caption(day.civil, rtl: entry.labels.rtl)
          Spacer(minLength: 0)
          Text(day.hijri)
            .font(.system(size: 22, weight: .semibold, design: .serif))
            .foregroundStyle(Palette.cream)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.6)
          Spacer(minLength: 0)
          if !day.next.isEmpty {
            Text(day.next).font(.system(size: 11))
              .foregroundStyle(Palette.cream.opacity(0.7))
              .lineLimit(2).multilineTextAlignment(.center)
          }
        }
        .frame(maxWidth: .infinity)
      }
    } else if family == .accessoryInline || family == .accessoryCircular {
      Image(systemName: "moon")
    } else {
      Text(entry.labels.empty).font(.footnote)
        .foregroundStyle(family == .accessoryRectangular ? Color.primary : Palette.cream)
    }
  }
}

struct HijriWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "HijriWidget", provider: HijriProvider()) {
      HijriView(entry: $0)
    }
    .configurationDisplayName(Store.labels.hijri)
    .description(Store.labels.rtl ? "التاريخ الهجري والمناسبة القادمة" : "Today's Hijri date and the next occasion")
    .supportedFamilies([
      .systemSmall, .accessoryCircular, .accessoryRectangular, .accessoryInline,
    ])
  }
}

// MARK: - Tasbih

@available(iOSApplicationExtension 17.0, *)
struct TasbihTap: AppIntent {
  static var title: LocalizedStringResource = "Count"

  func perform() async throws -> some IntentResult {
    Store.tasbih += 1
    return .result()
  }
}

@available(iOSApplicationExtension 17.0, *)
struct TasbihReset: AppIntent {
  static var title: LocalizedStringResource = "Reset"

  func perform() async throws -> some IntentResult {
    Store.tasbih = 0
    return .result()
  }
}

struct TasbihEntry: TimelineEntry {
  let date: Date
  let count: Int
  let labels: Labels
}

struct TasbihProvider: TimelineProvider {
  func placeholder(in context: Context) -> TasbihEntry {
    TasbihEntry(date: .now, count: 12, labels: .english)
  }

  func getSnapshot(in context: Context, completion: @escaping (TasbihEntry) -> Void) {
    completion(TasbihEntry(date: .now, count: Store.tasbih, labels: Store.labels))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<TasbihEntry>) -> Void) {
    completion(
      Timeline(
        entries: [TasbihEntry(date: .now, count: Store.tasbih, labels: Store.labels)],
        policy: .never))
  }
}

@available(iOSApplicationExtension 17.0, *)
struct TasbihView: View {
  @Environment(\.widgetFamily) var family
  let entry: TasbihEntry

  var phrase: String {
    let p = entry.labels.phrases
    return p[(entry.count / 33) % p.count]
  }

  var count: String {
    let n = "\(entry.count)"
    guard entry.labels.rtl else { return n }
    return String(n.map { c in
      c.wholeNumberValue.map { Character(UnicodeScalar(0x0660 + $0)!) } ?? c
    })
  }

  var body: some View {
    Group {
      if family == .accessoryCircular {
        Button(intent: TasbihTap()) {
          ZStack {
            AccessoryWidgetBackground()
            Text(count).font(.system(size: 20, weight: .semibold).monospacedDigit())
              .minimumScaleFactor(0.5)
          }
        }
        .buttonStyle(.plain)
      } else {
        VStack(spacing: 6) {
          Text(phrase).font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Palette.brass).lineLimit(1)
          Button(intent: TasbihTap()) {
            Text(count)
              .font(.system(size: 40, weight: .bold).monospacedDigit())
              .foregroundStyle(Palette.cream)
              .minimumScaleFactor(0.5)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          Button(intent: TasbihReset()) {
            Text(entry.labels.reset).font(.system(size: 11))
              .foregroundStyle(Palette.cream.opacity(0.7))
          }
          .buttonStyle(.plain)
        }
      }
    }
    .direction(entry.labels)
    .widgetBackground(Palette.green, family: family)
  }
}

@available(iOSApplicationExtension 17.0, *)
struct TasbihWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "TasbihWidget", provider: TasbihProvider()) {
      TasbihView(entry: $0)
    }
    .configurationDisplayName(Store.labels.tasbih)
    .description(Store.labels.rtl ? "اضغط لتعدّ تسبيحك" : "Tap to count your dhikr")
    .supportedFamilies([.systemSmall, .accessoryCircular])
  }
}

// MARK: - Live Activity

// Must match the copy in Runner/AppDelegate.swift field for field.
struct PrayerActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var name: String
    var clock: String
    var at: Date
    var since: Date
  }

  var label: String
  var now: String
  var city: String
  var rtl: Bool
}

struct PrayerLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: PrayerActivityAttributes.self) { context in
      PrayerLockView(context: context)
        .activityBackgroundTint(Palette.green)
        .activitySystemActionForegroundColor(Palette.cream)
        .widgetURL(link("prayer"))
    } dynamicIsland: { context in
      let s = context.state
      let a = context.attributes
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          VStack(alignment: .leading, spacing: 2) {
            caption(a.label, rtl: a.rtl)
            Text(s.name).font(.system(size: 20, weight: .semibold, design: .serif))
              .lineLimit(1).minimumScaleFactor(0.6)
          }
          .padding(.leading, 4)
          .widgetLocale(a.rtl)
        }
        DynamicIslandExpandedRegion(.trailing) {
          VStack(alignment: .trailing, spacing: 2) {
            Text(s.clock).font(.system(size: 13)).foregroundStyle(.secondary)
            remaining(s, now: a.now)
              .font(.system(size: 20, weight: .semibold).monospacedDigit())
              .environment(\.locale, clockLocale)
              .foregroundStyle(Palette.brass)
          }
          .padding(.trailing, 4)
          .widgetLocale(a.rtl)
        }
        DynamicIslandExpandedRegion(.bottom) {
          ProgressView(timerInterval: s.since...max(s.at, s.since), countsDown: false) {
            EmptyView()
          } currentValueLabel: {
            EmptyView()
          }
          .tint(Palette.brass)
          .padding(.horizontal, 4)
        }
      } compactLeading: {
        Image(systemName: "moon.stars.fill").foregroundStyle(Palette.brass)
      } compactTrailing: {
        remaining(s, now: a.now)
          .monospacedDigit()
          .environment(\.locale, clockLocale)
          .frame(maxWidth: 56)
          .foregroundStyle(Palette.brass)
          .widgetLocale(a.rtl)
      } minimal: {
        Image(systemName: "moon.stars.fill").foregroundStyle(Palette.brass)
      }
      .widgetURL(link("prayer"))
    }
  }
}

/// Counts down to the prayer, then says it's due.
private func remaining(_ s: PrayerActivityAttributes.ContentState, now label: String) -> Text {
  s.at > Date()
    ? Text(timerInterval: Date()...s.at, countsDown: true)
    : Text(label)
}

struct PrayerLockView: View {
  let context: ActivityViewContext<PrayerActivityAttributes>

  var body: some View {
    let s = context.state
    let a = context.attributes
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .center) {
        VStack(alignment: .leading, spacing: 2) {
          caption(a.label, rtl: a.rtl)
          Text(s.name).font(.system(size: 26, weight: .semibold, design: .serif))
            .foregroundStyle(Palette.cream).lineLimit(1).minimumScaleFactor(0.6)
          if !a.city.isEmpty {
            Text(a.city).font(.system(size: 11)).foregroundStyle(Palette.cream.opacity(0.6))
          }
        }
        Spacer(minLength: 8)
        VStack(alignment: .trailing, spacing: 2) {
          (context.isStale ? Text(a.now) : remaining(s, now: a.now))
            .font(.system(size: 26, weight: .semibold).monospacedDigit())
            .environment(\.locale, clockLocale)
            .foregroundStyle(Palette.cream)
            .multilineTextAlignment(.trailing)
          Text(s.clock).font(.system(size: 13)).foregroundStyle(Palette.cream.opacity(0.75))
        }
      }
      ProgressView(timerInterval: s.since...max(s.at, s.since), countsDown: false) {
        EmptyView()
      } currentValueLabel: {
        EmptyView()
      }
      .tint(Palette.brass)
    }
    .padding(16)
    .environment(\.layoutDirection, a.rtl ? .rightToLeft : .leftToRight)
  }
}

@main
struct MuslimWidgets: WidgetBundle {
  var body: some Widget {
    PrayerWidget()
    AyahWidget()
    DuaWidget()
    NameWidget()
    HadithWidget()
    HijriWidget()
    PrayerLiveActivity()
    if #available(iOSApplicationExtension 17.0, *) {
      TasbihWidget()
    }
  }
}
