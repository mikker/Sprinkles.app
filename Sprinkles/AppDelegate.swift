//
//  AppDelegate.swift
//  Sprinkles
//
//  Created by Mikkel Malmberg on 16/01/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import Cocoa
import Defaults

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
        
        if (Defaults[.enableDockIcon]) { NSApp.setActivationPolicy(.regular) }

        if (Defaults[.enableDiagnostics]) { Diagnostics.enable() }
        Diagnostics.send("Appliction boot")
        
        unsubscribe = store.subscribe { state in
            if state.hasCert && Defaults[.hasOnboarded] {
                Server.instance.start(3133)
            }
        }
        
        if !Defaults[.hasOnboarded] {
            self.onboarding.showWindow(nil)
            self.preferences!.close()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        Server.instance.stop()
        unsubscribe?()
    }
    
    private func showPreferences() {
        preferences!.makeKeyAndOrderFront(nil)
    }
    
    private func showOnboarding() {
        Defaults[.hasOnboarded] = false
        self.onboarding.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
