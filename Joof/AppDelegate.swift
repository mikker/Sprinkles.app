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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var unsubscribe: UnsubscribeFn?
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    let preferencesWindowController = PreferencesWindowController(
        viewControllers: [GeneralPreferencesViewController()]
    )

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initSentry()

        if let menubarButton = statusItem.button {
            menubarButton.image = NSImage(named: NSImage.Name("ToolbarItemIcon"))
        }

        buildMenubarMenu()

        JoofCertificate.generateCertsIfMissing { hasCert in
            store.dispatch(.hasCert(hasCert))
        }

        if let directory = Bookmark.url {
            store.dispatch(.setDirectory(directory))
        } else {
            preferencesWindowController.showWindow()
//            openSafariExtensionsIfDisabled()
        }

        unsubscribe = store.subscribe { state in
            if state.directory != nil && state.hasCert {
                NSApp.setActivationPolicy(.accessory)
                Server.instance.start(3133)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        Server.instance.stop()
        unsubscribe?()
    }

    @objc func showPreferences() {
        preferencesWindowController.showWindow()
    }

    private func initSentry() {
        do {
            Client.shared = try Client(dsn: "https://b0298bed5c364de2862c0760a881112b@sentry.io/1404238")
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
        }

        Client.shared?.user = User(userId: defaults[.userId])

        let event = Event(level: .info)
        event.message = "Joof booted"
        Client.shared?.send(event: event, completion: nil)
    }

    private func buildMenubarMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Preferences…", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Joof", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    private func openSafariExtensionsIfDisabled() {
        let identifier = "com.brnbw.Joof.extension"
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: identifier) { (state, error) in
            guard error == nil else { print(error!); return }
            guard state == nil || !(state!.isEnabled) else { return }

            SFSafariApplication.showPreferencesForExtension(withIdentifier: identifier, completionHandler: nil)
        }
    }
}
