//
//  AppDelegate.swift
//  Sprinkles
//
//  Created by Mikkel Malmberg on 16/01/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import Cocoa
import Defaults
import Preferences

extension PreferencePane.Identifier {
  static let general = Identifier("general")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet var onboarding: OnboardingController!

  lazy var preferences = PreferencesWindowController(
    preferencePanes: [GeneralPreferencesController()], style: .segmentedControl)

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    _ = Defaults.observe(.enableDiagnostics) { (state) in
      guard state.newValue else { return }
      Diagnostics.enable()
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
