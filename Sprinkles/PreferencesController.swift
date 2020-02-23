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
import SafariServices

class PreferencesController: NSViewController {
    @IBOutlet var statusLight: NSButton!
    @IBOutlet var statusLabel: NSTextField!
    @IBOutlet var directoryPathControl: NSPathControl!
    @IBOutlet var launchAtLoginCheckbox: NSButton!
    @IBOutlet var dockIconCheckbox: NSButton!
    @IBOutlet var diagnosticsCheckbox: NSButton!
    @IBOutlet var safariButton: NSButton!
    @IBOutlet var firefoxButton: NSButton!
    @IBOutlet var chromeButton: NSButton!
    
    var unsubscribe: UnsubscribeFn?
    var dockTimer: Timer?
    var diagnosticsObservation: DefaultsObservation?
    var dockIconObservation: DefaultsObservation?

    deinit {
        unsubscribe?()
    }
    
    override func viewDidLoad() {
        unsubscribe = store.subscribe { state in
            self.directoryPathControl.url = state.directory
            
            switch state.serverState {
            case .booting:
                self.statusLight.image = NSImage(named: NSImage.statusPartiallyAvailableName)
                self.statusLabel.stringValue = "Booting…"
            case .stopped:
                self.statusLight.image = NSImage(named: NSImage.statusUnavailableName)
                self.statusLabel.stringValue = "Stopped"
            case .running:
                self.statusLight.image = NSImage(named: NSImage.statusAvailableName)
                self.statusLabel.stringValue = "Running"
            }
        }
        
        diagnosticsObservation = Defaults.observe(.enableDiagnostics) { (change) in
            self.diagnosticsCheckbox.state = change.newValue ? .on : .off
        }.tieToLifetime(of: self)
        
        dockIconObservation = Defaults.observe(.enableDockIcon) { change in
            self.dockIconCheckbox.state = change.newValue ? .on : .off
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
    
    @IBAction func launchAtStartupPressed(_ sender: Any?) {
        let state = launchAtLoginCheckbox.state.rawValue == 1
        LaunchAtLogin.isEnabled = state
    }
    
    @IBAction func diagnosticsCheckboxPressed(_ sender: Any?) {
        let state = diagnosticsCheckbox.state.rawValue == 1
        Defaults[.enableDiagnostics] = state
    }
    
    @IBAction func dockIconCheckboxPressed(_ sender: Any?) {
        dockTimer?.invalidate()
        
        dockTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            let state = self.dockIconCheckbox.state.rawValue == 1
            
            Defaults[.enableDockIcon] = state
            
            NSApp.setActivationPolicy(state ? .regular : .accessory)
            
            if state == false { NSApp.activate(ignoringOtherApps: true) }
        })
    }
    
    @IBAction func supportPressed(_ sender: Any?) {
        NSWorkspace.shared.open(URL(string: "https://sprinkles.website/")!)
    }
    
    @IBAction func safariPressed(_ sender: Any?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.brnbw.Sprinkles.extension", completionHandler: nil)
    }
    
    @IBAction func firefoxPressed(_ sender: Any?) {
        NSWorkspace.shared.openFile("https://sprinkles.website/firefox", withApplication: "Firefox")
    }
    
    @IBAction func chromePressed(_ sender: Any?) {
        NSWorkspace.shared.openFile("https://sprinkles.website/chrome", withApplication: "Google Chrome")
    }
    
    @IBAction func quitPressed(_ sender: Any?) {
        NSApp.terminate(nil)
    }
}
