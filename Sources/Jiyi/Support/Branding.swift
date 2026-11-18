import Foundation

/// Single source of truth for the app's brand strings. Lets us swap
/// the visible name in one place if we ever rename, and keeps the
/// dozens of stringly-typed references in code consistent.
enum Branding {
    /// The name users see: "Jiyi" in English, 寄译 in Chinese, following
    /// the UI language like every other string (the bundle's display name
    /// does the same through InfoPlist.strings, written by Scripts/build.sh).
    static var appName: String { L.pick("Jiyi", "寄译") }
    static let bundleIdentifier = "io.github.okayzk.Jiyi"

    /// GitHub repo path used for the update-check API call and as a
    /// destination for the "open release page" deep link.
    static let githubRepoPath = "okayzk/Jiyi"

    /// Human-readable version string for display in the settings header
    /// and elsewhere.
    ///
    /// Reads `CFBundleShortVersionString` from `Info.plist`, which
    /// `Scripts/build.sh` takes from `VERSION` in app.env (e.g. "0.9.0").
    /// Local `swift run` builds have no Info.plist at all and show "dev".
    static var versionDisplay: String {
        guard let raw = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              !raw.isEmpty,
              raw != "dev",
              raw.first?.isNumber == true else {
            return "dev"
        }
        return "v\(raw)"
    }

    /// Returns the semver portion only ("0.9.0"), or nil for dev builds.
    static var releaseVersion: String? {
        guard let raw = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              !raw.isEmpty,
              raw != "dev",
              raw.first?.isNumber == true else {
            return nil
        }
        return raw
    }

    /// Release page URL for the current version (or the latest releases
    /// list when this is a dev build).
    static var currentReleaseURL: URL {
        if let v = releaseVersion {
            return URL(string: "https://github.com/\(githubRepoPath)/releases/tag/v\(v)")!
        }
        return URL(string: "https://github.com/\(githubRepoPath)/releases")!
    }
}
