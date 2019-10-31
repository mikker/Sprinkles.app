//
//  AppDelegate.swift
//  Joof
//
//  Created by Mikkel Malmberg on 16/01/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import Cocoa
import Preferences
import Defaults
import SafariServices
import Sentry
import Sparkle

extension PreferencePane.Identifier {
    static let general = Identifier("general")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var unsubscribe: UnsubscribeFn?
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
  
    @IBOutlet var onboarding: OnboardingController!

    lazy var preferences: [PreferencePane] = [
        GeneralPreferencesViewController()
    ]

    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: preferences,
        style: .segmentedControl,
        animated: true,
        hidesToolbarForSingleItem: true
    )

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initSentry()
        
        if let menubarButton = statusItem.button {
            menubarButton.image = NSImage(named: NSImage.Name("ToolbarItemIcon"))
        }

        buildMenubarMenu()

        unsubscribe = store.subscribe { state in
            if state.directory != nil && state.hasCert && Defaults[.hasOnboarded] {
                Server.instance.start(3133)
                NSApp.setActivationPolicy(.accessory)
            }
        }
        
        if !Defaults[.hasOnboarded] {
            self.onboarding.showWindow(nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        Server.instance.stop()
        unsubscribe?()
    }

    @objc func showPreferences() {
        preferencesWindowController.show()
    }
    
    @objc func showOnboarding() {
        Defaults[.hasOnboarded] = false
        NSApp.setActivationPolicy(.regular)
        self.onboarding.showWindow(nil)
    }

    private func initSentry() {
        do {
            Client.shared = try Client(dsn: "https://b0298bed5c364de2862c0760a881112b@sentry.io/1404238")
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
        }

        Client.shared?.user = User(userId: Defaults[.userId])

        let event = Event(level: .info)
        event.message = "Joof booted"
        Client.shared?.send(event: event, completion: nil)
    }

    private func buildMenubarMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Preferences…", action: #selector(showPreferences), keyEquivalent: ","))
        let alternate = NSMenuItem(title: "Onboarding…", action: #selector(showOnboarding), keyEquivalent: ",")
        alternate.isAlternate = true
        alternate.keyEquivalentModifierMask = .option
        menu.addItem(alternate)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Joof", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }
}
