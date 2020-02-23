//
//  StatusItem.swift
//  Sprinkles
//
//  Created by Mikkel Malmberg on 23/02/2020.
//  Copyright © 2020 Brainbow. All rights reserved.
//

import Cocoa

class StatusItem {
    var statusItem: NSStatusItem?
    
    var handlePreferences: (() -> Void)?
    var handleOnboarding: (() -> Void)?

    func enable() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let item = statusItem else { print("No status item"); return }
        
        if let menubarButton = item.button {
            menubarButton.image = NSImage(named: NSImage.Name("ToolbarItemIcon"))
        }

        let menu = NSMenu()

        let preferencesItem = NSMenuItem(title: "Preferences…", action: #selector(showPreferences), keyEquivalent: ",")
        preferencesItem.target = self
        menu.addItem(preferencesItem)
        
        let onboardingItem = NSMenuItem(title: "Onboarding…", action: #selector(showOnboarding), keyEquivalent: ",")
        onboardingItem.target = self
        onboardingItem.isAlternate = true
        onboardingItem.keyEquivalentModifierMask = .option
        menu.addItem(onboardingItem)
        
        let directoryItem = NSMenuItem(title: "Open directory…", action: #selector(openDirectory), keyEquivalent: "o")
        directoryItem.target = self
        menu.addItem(directoryItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Sprinkles", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        item.menu = menu
    }
    
    @objc func openDirectory() {
        NSWorkspace.shared.open(store.state.directory)
    }
    
    @objc func showPreferences() {
        guard let cb = handlePreferences else { return }
        cb()
    }
    
    @objc func showOnboarding() {
        guard let cb = handleOnboarding else { return }
        cb()
    }
}
