import Cocoa
import Preferences
import LaunchAtLogin
import Defaults

final class GeneralPreferencesViewController: NSViewController, Preferenceable {
    let toolbarItemTitle = "General"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!

    var unsubscribe: UnsubscribeFn?

    @IBOutlet var statusLight: StatusLightView!
    @IBOutlet var statusLabel: NSTextField!
    @IBOutlet var directoryPathControl: NSPathControl!
    @IBOutlet var launchAtLoginCheckbox: NSButton!
    @IBOutlet var installationInstructionsButton: NSButton!
    @IBOutlet var quitButton: NSButton!

    override var nibName: NSNib.Name? {
        return "GeneralPreferencesViewController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        unsubscribe = store.subscribe { state in
            self.directoryPathControl.url = state.directory

            switch state.serverState {
            case .booting:
                self.statusLight.color = NSColor.yellow
                self.statusLabel.stringValue = "Booting…"
            case .stopped:
                self.statusLight.color = NSColor.red
                self.statusLabel.stringValue = "Stopped"
            case .running:
                self.statusLight.color = NSColor.green
                self.statusLabel.stringValue = "Running"
            }
        }

        launchAtLoginCheckbox.state = LaunchAtLogin.isEnabled ? .on : .off
    }

    deinit {
        unsubscribe?()
    }

    @IBAction func pickDirectoryPressed(_ sender: Any?) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        let path = NSString(string: store.state.directory?.path ?? "~").expandingTildeInPath
        openPanel.directoryURL = NSURL.fileURL(withPath: path, isDirectory: true)
        openPanel.canChooseFiles = false
        openPanel.resolvesAliases = true
        openPanel.begin { (result) in
            guard result == NSApplication.ModalResponse.OK else { return }
            Bookmark.url = openPanel.url
            store.dispatch(.setDirectory(openPanel.url))
        }
    }

    @IBAction func launchAtStartupPressed(_ sender: Any?) {
        let state = launchAtLoginCheckbox.state.rawValue == 1
        LaunchAtLogin.isEnabled = state
    }

    @IBAction func installationInstructionsPressed(_ sender: Any?) {
        NSWorkspace.shared.open(URL(string: "https://joof.app/installation-instructions")!)
    }

    @IBAction func quitPressed(_ sender: Any?) {
        NSApplication.shared.terminate(nil)
    }
}
