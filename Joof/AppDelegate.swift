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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var unsubscribe: UnsubscribeFn?
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    let preferencesWindowController = PreferencesWindowController(
        viewControllers: [GeneralPreferencesViewController()]
    )

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)

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
        }

        openSafariExtensionsIfDisabled()

        unsubscribe = store.subscribe { state in
            if state.directory != nil && state.hasCert {
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
