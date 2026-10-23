// Frames the +5 / +6 marketing shots. Does not touch the published 01–08 set.
//
//   swiftc -parse-as-library store/play/frame_updates.swift -o /tmp/frame_updates && /tmp/frame_updates
//
// Reads  store/play/screenshots/raw/updates/{en,ar}/*.png
// Writes store/play/screenshots/updates/{en,ar}/01.jpg … at 1080×1920
// and    store/appstore/screenshots/updates/{en,ar}/01.jpg … at 1290×2796.
import AppKit
import SwiftUI

let green = Color(red: 0x1E / 255, green: 0x4D / 255, blue: 0x3A / 255)
let greenLight = Color(red: 0x2B / 255, green: 0x6B / 255, blue: 0x51 / 255)
let greenDeep = Color(red: 0x12 / 255, green: 0x33 / 255, blue: 0x26 / 255)
let brassLight = Color(red: 0xE8 / 255, green: 0xC0 / 255, blue: 0x6A / 255)
let cream = Color(red: 0xF7 / 255, green: 0xF1 / 255, blue: 0xE3 / 255)

let captions: [String: [(String, String)]] = [
  "en": [
    ("A sky that follows the day", "Prayer times under a living sky"),
    ("A compass that turns with you", "Qibla from your location"),
    ("A sebha in your hand", "Choose the beads and the color"),
    ("Tawashih", "Prophetic praise, ready to play"),
    ("Quran Radio", "Live from Cairo"),
    ("Share a beautiful card", "Hadith, names and duas"),
  ],
  "ar": [
    ("سماء تتبدّل مع الوقت", "مواقيت الصلاة تحت سماء حية"),
    ("بوصلة تدور مع هاتفك", "القبلة من موقعك"),
    ("مسبحة بين يديك", "اختر النوع واللون"),
    ("تواشيح", "مدائح نبوية جاهزة للسماع"),
    ("إذاعة القرآن الكريم", "بث مباشر من القاهرة"),
    ("شارك بطاقة جميلة", "الحديث والأسماء والدعاء"),
  ],
]

struct Shot: View {
  let image: NSImage
  let title: String
  let sub: String
  let arabic: Bool
  let canvas: CGSize

  var body: some View {
    let s = canvas.width / 1080
    ZStack {
      RadialGradient(colors: [greenLight, green, greenDeep], center: .init(x: 0.5, y: 0.15),
                     startRadius: 0, endRadius: canvas.height)
      VStack(spacing: 0) {
        VStack(spacing: 18 * s) {
          Text(title)
            .font(arabic ? .system(size: 68 * s, weight: .bold) : .system(size: 60 * s, weight: .semibold, design: .serif))
            .foregroundStyle(cream)
          Text(sub)
            .font(.system(size: 34 * s, weight: .medium))
            .foregroundStyle(brassLight)
        }
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .minimumScaleFactor(0.5)
        .padding(.horizontal, 56 * s)
        .frame(height: canvas.height * 0.18)

        Image(nsImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .clipShape(RoundedRectangle(cornerRadius: 48 * s, style: .continuous))
          .overlay(RoundedRectangle(cornerRadius: 48 * s, style: .continuous)
            .stroke(cream.opacity(0.25), lineWidth: 5 * s))
          .shadow(color: .black.opacity(0.35), radius: 28 * s, y: 14 * s)
          .frame(maxWidth: canvas.width * 0.86, maxHeight: canvas.height * 0.74)
        Spacer(minLength: 0)
      }
      .padding(.top, 28 * s)
    }
    .frame(width: canvas.width, height: canvas.height)
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
      let raw = root.appendingPathComponent("raw/updates/\(lang)")
      let files = ((try? fm.contentsOfDirectory(atPath: raw.path)) ?? [])
        .filter { $0.lowercased().hasSuffix(".png") || $0.lowercased().hasSuffix(".jpg") }
        .sorted()
      if files.isEmpty { print("\(lang): no screenshots in \(raw.path)"); continue }
      let sizes: [(String, CGSize)] = [
        ("store/play/screenshots/updates/\(lang)", CGSize(width: 1080, height: 1920)),
        ("store/appstore/screenshots/updates/\(lang)", CGSize(width: 1290, height: 2796)),
      ]
      for (i, f) in files.enumerated() {
        guard let img = NSImage(contentsOf: raw.appendingPathComponent(f)) else { continue }
        let (title, sub) = i < lines.count ? lines[i] : ("", "")
        let name = String(format: "%02d.jpg", i + 1)
        for (dir, size) in sizes {
          let out = URL(fileURLWithPath: dir)
          try? fm.createDirectory(at: out, withIntermediateDirectories: true)
          render(Shot(image: img, title: title, sub: sub, arabic: lang == "ar", canvas: size),
                 to: out.appendingPathComponent(name))
          print("\(dir)/\(name)  ← \(f)")
        }
      }
    }
  }
}
