//
//  MainWindow.swift
//  Sprinkles
//
//  Created by Mikkel Malmberg on 08/02/2020.
//  Copyright © 2020 Brainbow. All rights reserved.
//

import Cocoa
import Defaults
import LaunchAtLogin
import Preferences
import SafariServices

class GeneralPreferencesController: NSViewController, PreferencePane {
  var preferencePaneIdentifier = Preferences.PaneIdentifier.general
  var preferencePaneTitle = "General"

  override var nibName: NSNib.Name? { "General" }

  @IBOutlet var statusLight: NSButton!
  @IBOutlet var directoryPathControl: NSPathControl!
  @IBOutlet var pickLocationButton: NSButton!
  @IBOutlet var revealButton: NSButton!
  @IBOutlet var showPreferencesOnLaunchCheckbox: NSButton!
  @IBOutlet var launchAtLoginCheckbox: NSButton!
  @IBOutlet var diagnosticsCheckbox: NSButton!
  @IBOutlet var safariButton: NSButton!
  @IBOutlet var firefoxButton: NSButton!
  @IBOutlet var chromeButton: NSButton!

  var unsubscribe: UnsubscribeFn?
  var dockTimer: Timer?

  deinit {
    unsubscribe?()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.preferredContentSize = NSSize(width: 480, height: 462)

    unsubscribe = store.subscribe { state in
      self.directoryPathControl.url = state.directory
      self.revealButton.isEnabled = state.directory != nil

      switch state.serverState {
      case .booting:
        self.statusLight.image = NSImage(named: NSImage.statusPartiallyAvailableName)
        self.statusLight.title = "Booting…"
      case .stopped:
        self.statusLight.image = NSImage(named: NSImage.statusUnavailableName)
        self.statusLight.title = "Stopped"
      case .running:
        self.statusLight.image = NSImage(named: NSImage.statusAvailableName)
        self.statusLight.title = "Running on localhost:3133"
      }
    }

    _ = Defaults.observe(.enableDiagnostics) { (change) in
      self.diagnosticsCheckbox.state = change.newValue ? .on : .off
    }.tieToLifetime(of: self)

    launchAtLoginCheckbox.state = LaunchAtLogin.isEnabled ? .on : .off
  }

  @IBAction func chooseLocationPressed(_ sender: Any?) {
    OpenPanel.pick { result in
      guard let url = result else { return }

      Bookmark.url = url
      store.dispatch(.setDirectory(url))
    }
  }

  @IBAction func revealButtonPressed(_ sender: Any?) {
    guard let dir = store.state.directory else { return }
    NSWorkspace.shared.open(dir)
  }

  @IBAction func showPreferencesOnLaunchPressed(_ sender: Any?) {
    Defaults[.showPreferencesOnLaunch] = showPreferencesOnLaunchCheckbox.state == .on
  }

  @IBAction func launchAtStartupPressed(_ sender: Any?) {
    LaunchAtLogin.isEnabled = launchAtLoginCheckbox.state == .on
  }

  @IBAction func diagnosticsCheckboxPressed(_ sender: Any?) {
    Defaults[.enableDiagnostics] = diagnosticsCheckbox.state == .on
  }

  @IBAction func supportPressed(_ sender: Any?) {
    NSWorkspace.shared.open(URL(string: "https://getsprinkles.app/")!)
  }

  @IBAction func safariPressed(_ sender: Any?) {
    SFSafariApplication.showPreferencesForExtension(
      withIdentifier: "com.brnbw.Sprinkles.extension", completionHandler: nil)
  }

  @IBAction func firefoxPressed(_ sender: Any?) {
    NSWorkspace.shared.openFile("https://getsprinkles.app/firefox", withApplication: "Firefox")
  }

  @IBAction func chromePressed(_ sender: Any?) {
    NSWorkspace.shared.openFile(
      "https://getsprinkles.app/chrome", withApplication: "Google Chrome")
  }
}
