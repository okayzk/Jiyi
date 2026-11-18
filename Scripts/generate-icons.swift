// Draws the app icon and packs it into Resources/AppIcon.icns. Run from the repository root:
//
//   swift Scripts/generate-icons.swift                   Resources/AppIcon.iconset + AppIcon.icns
//   swift Scripts/generate-icons.swift --png <out.png>   one 1024 px image (docs/icon.png)
//
// The drawing is the source of truth: every size is drawn from it, so 16 px stays sharp.
// It shows a wild goose flying behind a glass speech bubble and out of it. The goose is the messenger of
// 鸿雁传书, the bird that carries letters, for 寄 in 寄译: the app carries your words into
// another language. The bubble is the translation tooltip itself.
import AppKit
import CoreImage

let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!

func rgb(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 0xff) / 255, green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat(hex & 0xff) / 255, alpha: alpha)
}
func white(_ alpha: CGFloat) -> CGColor { CGColor(gray: 1, alpha: alpha) }
func gradient(_ colors: [CGColor]) -> CGGradient {
    CGGradient(colorsSpace: sRGB, colors: colors as CFArray, locations: nil)!
}

// The palette: one bright sky blue, lighter at the top.
let skyTop = rgb(0x86D3FF)
let skyBottom = rgb(0x4A9FF5)
let shade = rgb(0x0B4FA8)   // shadows under the bubble and the goose

// Geometry in a 1024-unit canvas, on Apple's macOS icon grid: an 824-unit tile.
let tileRect = CGRect(x: 100, y: 100, width: 824, height: 824)
let tilePath = CGPath(roundedRect: tileRect, cornerWidth: 185, cornerHeight: 185, transform: nil)
// Both move together by `groupOffset`, which sets the composition's balance in the tile;
// `gooseShift` sets how far the goose has flown out of the bubble (head, neck and raised
// wing clear of the glass, body and tail behind it).
let groupOffset = CGPoint(x: 20, y: 10)
let gooseShift = CGPoint(x: 90, y: 80)
let frostSigma: Double = 14
let bubbleRect = CGRect(x: 214, y: 300, width: 520, height: 380).offsetBy(dx: groupOffset.x, dy: groupOffset.y)
let gooseBox = CGRect(x: 236, y: 250, width: 620, height: 580)
    .offsetBy(dx: groupOffset.x + gooseShift.x, dy: groupOffset.y + gooseShift.y)
let gooseTilt: CGFloat = 0.26

/// A speech bubble: a rounded body with a short tail at the lower left, as one outline so
/// that its rim has no seam.
func bubblePath(_ r: CGRect) -> CGPath {
    let body = CGPath(roundedRect: r, cornerWidth: r.height * 0.42, cornerHeight: r.height * 0.42, transform: nil)
    let tail = CGMutablePath()
    tail.move(to: CGPoint(x: r.minX + r.width * 0.24, y: r.minY + 20))
    tail.addCurve(to: CGPoint(x: r.minX + r.width * 0.17, y: r.minY - r.height * 0.12),
                  control1: CGPoint(x: r.minX + r.width * 0.24, y: r.minY - r.height * 0.04),
                  control2: CGPoint(x: r.minX + r.width * 0.21, y: r.minY - r.height * 0.09))
    tail.addCurve(to: CGPoint(x: r.minX + r.width * 0.38, y: r.minY + 20),
                  control1: CGPoint(x: r.minX + r.width * 0.26, y: r.minY - r.height * 0.09),
                  control2: CGPoint(x: r.minX + r.width * 0.33, y: r.minY - r.height * 0.03))
    tail.closeSubpath()
    return body.union(tail)
}

/// The goose in a 100-unit box, flying to the right: neck stretched forward, the near wing
/// raised, the far wing lowered (drawn dimmer, behind).
func goosePaths() -> (near: CGPath, far: CGPath) {
    // Head, neck, body and tail as one outline, clockwise from the beak tip.
    let body = CGMutablePath()
    body.move(to: CGPoint(x: 94, y: 55.5))                                          // beak tip
    body.addCurve(to: CGPoint(x: 86, y: 59),                                        // crown
                  control1: CGPoint(x: 91, y: 57.5), control2: CGPoint(x: 88.5, y: 59))
    body.addCurve(to: CGPoint(x: 68, y: 51),                                        // down the neck
                  control1: CGPoint(x: 81, y: 59), control2: CGPoint(x: 75, y: 53))
    body.addCurve(to: CGPoint(x: 34, y: 47),                                        // the back
                  control1: CGPoint(x: 58, y: 49.5), control2: CGPoint(x: 45, y: 49))
    body.addCurve(to: CGPoint(x: 22, y: 45),                                        // tail, upper edge
                  control1: CGPoint(x: 29, y: 46.5), control2: CGPoint(x: 25, y: 46.5))
    body.addCurve(to: CGPoint(x: 33, y: 39.5),                                      // round tail tip
                  control1: CGPoint(x: 20, y: 43), control2: CGPoint(x: 27, y: 40))
    body.addCurve(to: CGPoint(x: 63, y: 42),                                        // belly
                  control1: CGPoint(x: 43, y: 37), control2: CGPoint(x: 55, y: 37.5))
    body.addCurve(to: CGPoint(x: 84, y: 53.5),                                      // throat
                  control1: CGPoint(x: 71, y: 46), control2: CGPoint(x: 78, y: 51.5))
    body.addCurve(to: CGPoint(x: 94, y: 55.5),                                      // under the beak
                  control1: CGPoint(x: 88, y: 54.5), control2: CGPoint(x: 91, y: 55))
    body.closeSubpath()

    // The near wing; its root sits inside the body so the back stays smooth.
    let wing = CGMutablePath()
    wing.move(to: CGPoint(x: 61, y: 46))
    wing.addCurve(to: CGPoint(x: 27, y: 91), control1: CGPoint(x: 59, y: 64), control2: CGPoint(x: 46, y: 83))
    wing.addCurve(to: CGPoint(x: 42, y: 45), control1: CGPoint(x: 36, y: 77), control2: CGPoint(x: 41, y: 60))
    wing.closeSubpath()

    let far = CGMutablePath()
    far.move(to: CGPoint(x: 57, y: 42))
    far.addCurve(to: CGPoint(x: 37, y: 11), control1: CGPoint(x: 55, y: 28), control2: CGPoint(x: 46, y: 16))
    far.addCurve(to: CGPoint(x: 44, y: 42), control1: CGPoint(x: 40, y: 22), control2: CGPoint(x: 42, y: 33))
    far.closeSubpath()
    return (body.union(wing), far)
}

/// The icon at `side` pixels. Everything is laid out in 1024 units; `unit` converts the
/// few values that do not scale with the context (shadow blurs, the blur under the glass).
func drawIcon(side: Int) -> CGImage {
    let unit = CGFloat(side) / 1024
    func context() -> CGContext {
        let c = CGContext(data: nil, width: side, height: side, bitsPerComponent: 8, bytesPerRow: 0, space: sRGB,
                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        c.scaleBy(x: unit, y: unit)
        return c
    }
    let canvas = CGRect(x: 0, y: 0, width: 1024, height: 1024)

    // 1. The sky and the goose: everything behind the glass.
    let sky = context()
    sky.saveGState()
    sky.addPath(tilePath); sky.clip()
    sky.drawLinearGradient(gradient([skyTop, skyBottom]), start: CGPoint(x: 512, y: tileRect.maxY),
                           end: CGPoint(x: 512, y: tileRect.minY), options: [])
    sky.drawRadialGradient(gradient([white(0.40), white(0)]),
                           startCenter: CGPoint(x: 300, y: 860), startRadius: 0,
                           endCenter: CGPoint(x: 300, y: 860), endRadius: 700, options: [])
    sky.restoreGState()
    // The goose flies behind the bubble, so it is part of what the glass frosts.
    let (near, far) = goosePaths()
    sky.saveGState()
    sky.translateBy(x: gooseBox.midX, y: gooseBox.midY)
    sky.rotate(by: gooseTilt)
    sky.scaleBy(x: gooseBox.width / 100, y: gooseBox.height / 100)
    sky.translateBy(x: -55, y: -50)
    sky.setShadow(offset: CGSize(width: 0, height: -7 * unit), blur: 18 * unit, color: shade.copy(alpha: 0.45)!)
    sky.beginTransparencyLayer(auxiliaryInfo: nil)
    sky.addPath(far); sky.setFillColor(white(0.78)); sky.fillPath()
    sky.addPath(near); sky.setFillColor(white(1)); sky.fillPath()
    sky.endTransparencyLayer()
    sky.restoreGState()
    let backdrop = sky.makeImage()!
    let pixels = CGRect(x: 0, y: 0, width: side, height: side)
    let frosted = CIContext().createCGImage(
        CIImage(cgImage: backdrop).clampedToExtent().applyingGaussianBlur(sigma: frostSigma * Double(unit)).cropped(to: pixels),
        from: pixels)!

    let c = context()
    // The tile and its shadow.
    c.saveGState()
    c.setShadow(offset: CGSize(width: 0, height: -10 * unit), blur: 24 * unit, color: CGColor(gray: 0, alpha: 0.3))
    c.addPath(tilePath); c.setFillColor(skyBottom); c.fillPath()
    c.restoreGState()
    c.addPath(tilePath); c.clip()
    c.draw(backdrop, in: canvas)
    c.drawLinearGradient(gradient([white(0.18), white(0)]), start: CGPoint(x: 512, y: tileRect.maxY),
                         end: CGPoint(x: 512, y: 560), options: [])

    // 2. The glass bubble: its shadow, the frosted sky inside it, a sheen and a rim.
    let bubble = bubblePath(bubbleRect)
    c.saveGState()
    c.setShadow(offset: CGSize(width: 0, height: -16 * unit), blur: 48 * unit, color: shade.copy(alpha: 0.35)!)
    c.addPath(bubble); c.setFillColor(white(1)); c.fillPath()
    c.restoreGState()
    c.saveGState()
    c.addPath(bubble); c.clip()
    c.draw(frosted, in: canvas)
    c.setFillColor(white(0.16)); c.fill(canvas)
    c.drawLinearGradient(gradient([white(0.38), white(0)]),
                         start: CGPoint(x: bubbleRect.minX, y: bubbleRect.maxY),
                         end: CGPoint(x: bubbleRect.midX, y: bubbleRect.midY), options: [])
    c.restoreGState()
    c.saveGState()
    c.addPath(bubble); c.setLineWidth(10); c.replacePathWithStrokedPath(); c.clip()
    c.drawLinearGradient(gradient([white(1), white(0.35)]),
                         start: CGPoint(x: bubbleRect.minX, y: bubbleRect.maxY),
                         end: CGPoint(x: bubbleRect.maxX, y: bubbleRect.minY), options: [])
    c.restoreGState()

    return c.makeImage()!
}

func writePNG(_ image: CGImage, to url: URL) throws {
    guard let data = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
        throw NSError(domain: "jiyi.icon", code: 1)
    }
    try data.write(to: url)
}

let arguments = CommandLine.arguments
if arguments.count == 3, arguments[1] == "--png" {
    try writePNG(drawIcon(side: 1024), to: URL(fileURLWithPath: arguments[2]))
    exit(0)
}

let resourcesURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("Resources", isDirectory: true)
let iconsetURL = resourcesURL.appendingPathComponent("AppIcon.iconset", isDirectory: true)
try? FileManager.default.removeItem(at: iconsetURL)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

for (name, side) in [("16x16", 16), ("16x16@2x", 32), ("32x32", 32), ("32x32@2x", 64),
                     ("128x128", 128), ("128x128@2x", 256), ("256x256", 256), ("256x256@2x", 512),
                     ("512x512", 512), ("512x512@2x", 1024)] {
    try writePNG(drawIcon(side: side), to: iconsetURL.appendingPathComponent("icon_\(name).png"))
}

let iconutil = Process()
iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
iconutil.arguments = ["-c", "icns", iconsetURL.path, "-o", resourcesURL.appendingPathComponent("AppIcon.icns").path]
try iconutil.run()
iconutil.waitUntilExit()
guard iconutil.terminationStatus == 0 else {
    throw NSError(domain: "jiyi.iconutil", code: Int(iconutil.terminationStatus))
}
print(resourcesURL.appendingPathComponent("AppIcon.icns").path)
