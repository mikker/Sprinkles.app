//
//  StatusItem.swift
//  Sprinkles
//
//  Created by Mikkel Malmberg on 23/02/2020.
//  Copyright © 2020 Brainbow. All rights reserved.
//

import Cocoa

class StatusItem: NSObject {
  var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

  override func awakeFromNib() {
    statusItem.button?.image = NSImage(named: NSImage.Name("ToolbarItemIcon"))
    statusItem.menu = buildMenu()
  }

  private func buildMenu() -> NSMenu {
    let menu = NSMenu()

    let preferencesItem = NSMenuItem(
      title: "Preferences…", action: #selector(showPreferences), keyEquivalent: ",")
    preferencesItem.target = self
    menu.addItem(preferencesItem)

    let onboardingItem = NSMenuItem(
      title: "Onboarding…", action: #selector(showOnboarding), keyEquivalent: ",")
    onboardingItem.target = self
    onboardingItem.isAlternate = true
    onboardingItem.keyEquivalentModifierMask = .option
    menu.addItem(onboardingItem)

    let directoryItem = NSMenuItem(
      title: "Open directory…", action: #selector(openDirectory), keyEquivalent: "o")
    directoryItem.target = self
    menu.addItem(directoryItem)

    menu.addItem(NSMenuItem.separator())
    menu.addItem(
      NSMenuItem(
        title: "Quit Sprinkles", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    )

    return menu
  }

  @objc func openDirectory() {
    if let directory = store.state.directory {
      NSWorkspace.shared.open(directory)
    } else {
      showPreferences()
    }
  }

  @objc func showPreferences() {
    guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
    delegate.showPreferences()
  }

  @objc func showOnboarding() {
    guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
    delegate.showOnboarding()
  }
}
