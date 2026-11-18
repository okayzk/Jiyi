import Combine
import Foundation
import Sparkle

/// New versions, found and installed by Sparkle from the signed appcast named in
/// Info.plist (`SUFeedURL` and `SUPublicEDKey`, written by `Scripts/build.sh`). Sparkle
/// shows its own windows. Automatic checks are on by default (once a day, set by
/// `SUEnableAutomaticChecks` so Sparkle does not ask first) and the user can turn them
/// off in Settings.
///
/// `swift run` has no Info.plist, and a build made before the update key existed has no
/// public key: neither can verify an update, so the updater is never started there and
/// `isAvailable` is false.
@MainActor
final class Updater: ObservableObject {
    static let shared = Updater()

    private let controller: SPUStandardUpdaterController?
    /// Mirrors Sparkle's own flag, which is false while a check is already running.
    @Published private(set) var canCheckForUpdates = false
    private var cancellables = Set<AnyCancellable>()

    private init() {
        let info = Bundle.main.infoDictionary ?? [:]
        guard info["SUFeedURL"] != nil, info["SUPublicEDKey"] != nil else {
            controller = nil
            AppLogger.log("updater: not configured in Info.plist, updates are off")
            return
        }
        let controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        self.controller = controller
        controller.updater.publisher(for: \.canCheckForUpdates)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.canCheckForUpdates = $0 }
            .store(in: &cancellables)
    }

    /// Starts the updater, so that the scheduled check runs. Called once at launch.
    func start() {}

    var isAvailable: Bool { controller != nil }

    var automaticallyChecksForUpdates: Bool {
        get { controller?.updater.automaticallyChecksForUpdates ?? false }
        set {
            objectWillChange.send()
            controller?.updater.automaticallyChecksForUpdates = newValue
        }
    }

    func checkNow() {
        controller?.checkForUpdates(nil)
    }
}
