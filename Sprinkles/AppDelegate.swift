import Cocoa
import Defaults
import Settings

extension Settings.PaneIdentifier {
  static let general = Self("general")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet var onboarding: OnboardingController!

  lazy var preferences = SettingsWindowController(
    panes: [GeneralPreferencesController()], style: .segmentedControl)

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if Defaults[.userId] == nil {
      Defaults[.userId] = UUID().uuidString
    }

    _ = store.subscribe { state in
      if state.hasCert && state.directory != nil {
        Server.instance.start(3133)
      }
    }

    if Defaults[.showPreferencesOnLaunch] {
      showPreferences()
    }

    if !Defaults[.hasOnboarded] {
      showOnboarding()
    }
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    Server.instance.stop()
  }

  func showPreferences() {
    preferences.show()
  }

  func showOnboarding() {
    Defaults[.hasOnboarded] = false
    self.onboarding.showWindow(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
}

extension NSApplication {
  func relaunch(afterDelay seconds: TimeInterval = 0.5) -> Never {
    let task = Process()
    task.launchPath = "/bin/sh"
    task.arguments = ["-c", "sleep \(seconds); open \"\(Bundle.main.bundlePath)\""]
    task.launch()

    self.terminate(nil)
    exit(0)
  }
}
