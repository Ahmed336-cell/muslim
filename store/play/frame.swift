// Frames raw phone screenshots for the store listing.
//
//   swiftc -parse-as-library store/play/frame.swift -o /tmp/frame && /tmp/frame
//
// Reads  store/play/screenshots/raw/{en,ar}/01.png, 02.png, …
// Writes store/play/screenshots/{en,ar}/01.jpg, … at 1080×1920 (9:16, no alpha).
// Captions are matched by order; edit them below.
import AppKit
import SwiftUI

let green = Color(red: 0x1E / 255, green: 0x4D / 255, blue: 0x3A / 255)
let greenLight = Color(red: 0x2B / 255, green: 0x6B / 255, blue: 0x51 / 255)
let greenDeep = Color(red: 0x12 / 255, green: 0x33 / 255, blue: 0x26 / 255)
let brassLight = Color(red: 0xE8 / 255, green: 0xC0 / 255, blue: 0x6A / 255)
let cream = Color(red: 0xF7 / 255, green: 0xF1 / 255, blue: 0xE3 / 255)

let captions: [String: [(String, String)]] = [
  "en": [
    ("Prayer times you can trust", "Adhan, countdown and a daily tracker"),
    ("Read the Mushaf", "Madinah pages with renowned reciters"),
    ("Morning, evening & sleep adhkar", "Shown at the right time, with counters"),
    ("Memorise with confidence", "Repeat, test and track your hifz"),
    ("Hadith library", "Nawawi's 40, Qudsi and Riyad as-Salihin"),
    ("Qibla, Hijri calendar & more", "Zakat, fasting, travel mode and widgets"),
    ("Learn and grow", "Wudu, salah, tajweed and a kids' corner"),
    ("No ads. No account.", "Your worship stays on your phone"),
  ],
  "ar": [
    ("مواقيت صلاة دقيقة", "أذان وعدّ تنازلي ومتابعة يومية"),
    ("اقرأ المصحف", "صفحات مصحف المدينة بأصوات كبار القرّاء"),
    ("أذكار الصباح والمساء والنوم", "في وقتها الصحيح مع العدّاد"),
    ("احفظ بثقة", "كرّر واختبر نفسك وتابع حفظك"),
    ("مكتبة الحديث", "الأربعون النووية والقدسية ورياض الصالحين"),
    ("القبلة والتقويم الهجري والمزيد", "الزكاة والصيام ووضع السفر والودجات"),
    ("تعلّم وارتقِ", "الوضوء والصلاة والتجويد وركن الأطفال"),
    ("بلا إعلانات ولا حساب", "عبادتك تبقى على هاتفك"),
  ],
]

struct Shot: View {
  let image: NSImage
  let title: String
  let sub: String
  let arabic: Bool

  var body: some View {
    ZStack {
      RadialGradient(colors: [greenLight, green, greenDeep], center: .init(x: 0.5, y: 0.2),
                     startRadius: 0, endRadius: 1500)
      VStack(spacing: 0) {
        VStack(spacing: 18) {
          Text(title)
            .font(arabic ? .system(size: 76, weight: .bold) : .system(size: 72, weight: .semibold, design: .serif))
            .foregroundStyle(cream)
          Text(sub)
            .font(.system(size: 40, weight: .medium))
            .foregroundStyle(brassLight)
        }
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .minimumScaleFactor(0.6)
        .padding(.horizontal, 70)
        .frame(height: 400)

        Image(nsImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .clipShape(RoundedRectangle(cornerRadius: 56, style: .continuous))
          .overlay(RoundedRectangle(cornerRadius: 56, style: .continuous)
            .stroke(cream.opacity(0.25), lineWidth: 6))
          .shadow(color: .black.opacity(0.35), radius: 30, y: 16)
          .frame(maxWidth: 860, maxHeight: 1360)
        Spacer(minLength: 0)
      }
      .padding(.top, 40)
    }
    .frame(width: 1080, height: 1920)
    .clipped()
  }
}

@MainActor func render(_ view: some View, to url: URL) {
  let r = ImageRenderer(content: view)
  r.scale = 1
  guard let cg = r.cgImage else { fatalError("render \(url.lastPathComponent)") }
  let rep = NSBitmapImageRep(cgImage: cg)
  let data = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.92])!
  try! data.write(to: url)
}

@main struct Main {
  @MainActor static func main() {
    let root = URL(fileURLWithPath: "store/play/screenshots")
    let fm = FileManager.default
    for (lang, lines) in captions {
      let raw = root.appendingPathComponent("raw/\(lang)")
      let files = ((try? fm.contentsOfDirectory(atPath: raw.path)) ?? [])
        .filter { $0.lowercased().hasSuffix(".png") || $0.lowercased().hasSuffix(".jpg") }
        .sorted()
      if files.isEmpty { print("\(lang): no screenshots in \(raw.path)"); continue }
      let out = root.appendingPathComponent(lang)
      try? fm.createDirectory(at: out, withIntermediateDirectories: true)
      for (i, f) in files.enumerated() {
        guard let img = NSImage(contentsOf: raw.appendingPathComponent(f)) else { continue }
        let (title, sub) = i < lines.count ? lines[i] : ("", "")
        let name = String(format: "%02d.jpg", i + 1)
        render(Shot(image: img, title: title, sub: sub, arabic: lang == "ar"),
               to: out.appendingPathComponent(name))
        print("\(lang)/\(name)  ← \(f)")
      }
    }
  }
}
