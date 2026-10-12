import SwiftUI
import WidgetKit

// Data is written by lib/services/home_widgets.dart through home_widget.
private let appGroup = "group.com.example.muslim"

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
    }
    return l
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

  static let english = Labels(
    rtl: false, next: "Next prayer", verse: "A verse", dua: "Dua",
    name: "Names of Allah", empty: "Open the app to load")
  static let arabic = Labels(
    rtl: true, next: "الصلاة القادمة", verse: "آية", dua: "دعاء",
    name: "أسماء الله الحسنى", empty: "افتح التطبيق للتحميل")
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

  fileprivate func direction(_ labels: Labels) -> some View {
    environment(\.layoutDirection, labels.rtl ? .rightToLeft : .leftToRight)
  }
}

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
      .multilineTextAlignment(entry.labels.rtl ? .trailing : .leading)
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
  case ayahs, duas, names

  var host: String {
    switch self {
    case .ayahs: "ayah"
    case .duas: "dua"
    case .names: "name"
    }
  }

  func title(_ l: Labels) -> String {
    switch self {
    case .ayahs: l.verse
    case .duas: l.dua
    case .names: l.name
    }
  }

  var sample: Item {
    switch self {
    case .ayahs: Item(text: "فإن مع العسر يسرا", sub: "", ref: "Ash-Sharh · 5")
    case .duas: Item(text: "رب زدني علما", sub: "My Lord, increase me in knowledge", ref: "")
    case .names: Item(text: "الرحمن", sub: "The Most Merciful", ref: "Ar-Rahman")
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

@main
struct MuslimWidgets: WidgetBundle {
  var body: some Widget {
    PrayerWidget()
    AyahWidget()
    DuaWidget()
    NameWidget()
  }
}
