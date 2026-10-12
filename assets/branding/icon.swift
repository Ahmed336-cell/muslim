import AppKit
import SwiftUI

let green = Color(red: 0x1E / 255, green: 0x4D / 255, blue: 0x3A / 255)
let greenLight = Color(red: 0x2B / 255, green: 0x6B / 255, blue: 0x51 / 255)
let greenDeep = Color(red: 0x12 / 255, green: 0x33 / 255, blue: 0x26 / 255)
let brassLight = Color(red: 0xE8 / 255, green: 0xC0 / 255, blue: 0x6A / 255)
let brass = Color(red: 0xB0 / 255, green: 0x81 / 255, blue: 0x2F / 255)
let cream = Color(red: 0xF7 / 255, green: 0xF1 / 255, blue: 0xE3 / 255)

/// Rub el Hizb: two squares, one turned 45°.
struct Star: Shape {
  func path(in r: CGRect) -> Path {
    let side = r.width / sqrt(2)
    let sq = CGRect(x: r.midX - side / 2, y: r.midY - side / 2, width: side, height: side)
    var p = Path(sq)
    p.addPath(Path(sq).applying(
      CGAffineTransform(translationX: r.midX, y: r.midY).rotated(by: .pi / 4)
        .translatedBy(x: -r.midX, y: -r.midY)))
    return p
  }
}

struct Crescent: Shape {
  func path(in r: CGRect) -> Path {
    let outer = CGPath(ellipseIn: r, transform: nil)
    let d = r.width * 0.84
    let inner = CGPath(
      ellipseIn: CGRect(x: r.minX + r.width * 0.30, y: r.minY + r.width * 0.02, width: d, height: d),
      transform: nil)
    return Path(outer.subtracting(inner))
  }
}

/// Four-pointed sparkle.
struct Sparkle: Shape {
  func path(in r: CGRect) -> Path {
    let c = CGPoint(x: r.midX, y: r.midY), R = r.width / 2, k = R * 0.22
    var p = Path()
    p.move(to: CGPoint(x: c.x, y: c.y - R))
    p.addQuadCurve(to: CGPoint(x: c.x + R, y: c.y), control: CGPoint(x: c.x + k, y: c.y - k))
    p.addQuadCurve(to: CGPoint(x: c.x, y: c.y + R), control: CGPoint(x: c.x + k, y: c.y + k))
    p.addQuadCurve(to: CGPoint(x: c.x - R, y: c.y), control: CGPoint(x: c.x - k, y: c.y + k))
    p.addQuadCurve(to: CGPoint(x: c.x, y: c.y - R), control: CGPoint(x: c.x - k, y: c.y - k))
    return p
  }
}

/// The emblem, drawn in a box of side [s]. [mono] draws one flat colour.
struct Emblem: View {
  let s: CGFloat
  var mono = false

  var body: some View {
    let brassFill = mono
      ? AnyShapeStyle(Color.white)
      : AnyShapeStyle(LinearGradient(colors: [brassLight, brass], startPoint: .top, endPoint: .bottom))
    ZStack {
      Star().fill(brassFill).frame(width: s, height: s)
      Circle().fill(mono ? Color.clear : green).frame(width: s * 0.64, height: s * 0.64)
      if mono {
        Circle().fill(Color.black).frame(width: s * 0.64, height: s * 0.64).blendMode(.destinationOut)
      }
      Circle().stroke(mono ? Color.white : brassLight.opacity(0.9), lineWidth: s * 0.018)
        .frame(width: s * 0.56, height: s * 0.56)
      Crescent().fill(mono ? Color.white : cream)
        .frame(width: s * 0.38, height: s * 0.38)
        .offset(x: -s * 0.035)
      Sparkle().fill(mono ? Color.white : cream)
        .frame(width: s * 0.11, height: s * 0.11)
        .offset(x: s * 0.10, y: -s * 0.02)
    }
    .compositingGroup()
    .frame(width: s, height: s)
  }
}

struct Background: View {
  let s: CGFloat
  var body: some View {
    ZStack {
      RadialGradient(colors: [greenLight, green, greenDeep], center: .init(x: 0.5, y: 0.42),
                     startRadius: 0, endRadius: s * 0.75)
      Star().stroke(brassLight.opacity(0.10), lineWidth: s * 0.006)
        .frame(width: s * 1.15, height: s * 1.15)
      Star().stroke(brassLight.opacity(0.07), lineWidth: s * 0.004)
        .frame(width: s * 0.86, height: s * 0.86)
    }
    .frame(width: s, height: s)
    .clipped()
  }
}

/// App name under the splash emblem.
struct Wordmark: View {
  var body: some View {
    HStack(spacing: 36) {
      Text("Sabeelak").font(.system(size: 64, weight: .semibold, design: .serif))
      Circle().fill(brassLight).frame(width: 12, height: 12)
      Text("سبيلك").font(.system(size: 72, weight: .bold))
    }
    .foregroundStyle(cream)
    .frame(width: 800, height: 160)
  }
}

@MainActor func save<V: View>(_ v: V, _ size: CGFloat, _ name: String, height: CGFloat? = nil) {
  let r = ImageRenderer(content: v.frame(width: size, height: height ?? size))
  r.scale = 1
  guard let cg = r.cgImage else { fatalError(name) }
  let rep = NSBitmapImageRep(cgImage: cg)
  try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "/tmp/icon/\(name).png"))
}

@main struct Main {
  @MainActor static func main() {
    let S: CGFloat = 1024
    save(ZStack { Background(s: S); Emblem(s: S * 0.62) }, S, "full")
    // Adaptive foreground: art inside the 66/108 safe zone.
    save(Emblem(s: S * 0.50), S, "foreground")
    save(Emblem(s: S * 0.50, mono: true), S, "monochrome")
    save(Background(s: S), S, "background")
    // Splash: emblem on transparent; Android 12 keeps art inside a 2/3 circle.
    save(Emblem(s: 480), 720, "splash")
    save(Emblem(s: 720), 1152, "splash_android12")
    save(Wordmark(), 800, "splash_branding", height: 160)
    print("done")
  }
}
