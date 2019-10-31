import Cocoa
import LaunchAtLogin
import Defaults
import Preferences
import SafariServices

final class GeneralPreferencesViewController: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.general
    let preferencePaneTitle = "Joof"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!

    var unsubscribe: UnsubscribeFn?

    @IBOutlet var statusLight: StatusLightView!
    @IBOutlet var statusLabel: NSTextField!
    @IBOutlet var directoryPathControl: NSPathControl!
    @IBOutlet var launchAtLoginCheckbox: NSButton!
    @IBOutlet var supportButton: NSButton!
    @IBOutlet var safariButton: NSButton!
    @IBOutlet var firefoxButton: NSButton!
    @IBOutlet var chromeButton: NSButton!
    @IBOutlet var quitButton: NSButton!
    @IBOutlet var cycleCertificatesButton: NSButton!
    @IBOutlet var passwordField: NSTextField!

    override var nibName: NSNib.Name? {
        return "GeneralPreferencesViewController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordField.stringValue = Defaults[.userId]

        self.preferredContentSize = NSSize(width: 480, height: 325)

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
        OpenPanel.pick { url in
            guard url != nil else { return }
            Bookmark.url = url!
            store.dispatch(.setDirectory(url!))
        }
    }

    @IBAction func launchAtStartupPressed(_ sender: Any?) {
        let state = launchAtLoginCheckbox.state.rawValue == 1
        LaunchAtLogin.isEnabled = state
    }

    @IBAction func supportPressed(_ sender: Any?) {
        NSWorkspace.shared.open(URL(string: "https://joof.app/")!)
    }

    @IBAction func safariPressed(_ sender: Any?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.brnbw.Joof.extension", completionHandler: nil)
    }
    
    @IBAction func firefoxPressed(_ sender: Any?) {
        NSWorkspace.shared.open(URL(string: "https://addons.mozilla.org/en-US/firefox/addon/joof-app/?src=search")!)
    }
    
    @IBAction func chromePressed(_ sender: Any?) {
        NSWorkspace.shared.open(URL(string: "https://chrome.google.com/webstore/detail/joofapp/knknjjghhkppgfkkclcdefohkfdnhfan")!)
    }
    
    @IBAction func cycleCertificatedPressed(_ sender: Any?) {
        cycleCertificatesButton.isEnabled = false

        JoofCertificate.destroy()
        
        NSApplication.shared.terminate(nil)
    }

    @IBAction func quitPressed(_ sender: Any?) {
        NSApplication.shared.terminate(nil)
    }
}
