//
//  AppDelegate.swift
//  Sprinkles
//
//  Created by Mikkel Malmberg on 16/01/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import Cocoa
import Defaults
import SafariServices
import Sentry
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = StatusItem()
    var unsubscribe: UnsubscribeFn?
    var preferences: NSWindow?
  
    @IBOutlet var onboarding: OnboardingController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        preferences = NSApplication.shared.windows.last!
        
        statusItem.handleOnboarding = { self.showOnboarding() }
        statusItem.handlePreferences = { self.showPreferences() }
        statusItem.enable()
        
        if (!Defaults[.enableDockIcon]) { NSApp.setActivationPolicy(.accessory) }

        if (Defaults[.enableDiagnostics]) { initSentry() }
        
        unsubscribe = store.subscribe { state in
            if state.hasCert && Defaults[.hasOnboarded] {
                Server.instance.start(3133)
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
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        preferences!.makeKeyAndOrderFront(sender)
        return true
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
        event.message = "Sprinkles booted"
        Client.shared?.send(event: event, completion: nil)
    }

    private func showPreferences() {
        preferences!.makeKeyAndOrderFront(nil)
    }
    
    private func showOnboarding() {
        Defaults[.hasOnboarded] = false
        self.onboarding.showWindow(nil)
    }
    
    @objc private func openDirectory() {
        NSWorkspace.shared.open(store.state.directory)
    }
}
