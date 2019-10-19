//
//  OnboardingWindow.swift
//  Joof
//
//  Created by Mikkel Malmberg on 13/10/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import Cocoa
import SafariServices
import Defaults
import LaunchAtLogin

class OnboardingController: NSWindowController {
    enum Page {
        case page1, page2, page3
    }
    
    @IBOutlet var step1: OnboardingStep1View!
    @IBOutlet var step2: OnboardingStep2View!
    @IBOutlet var step3: OnboardingStep3View!
    @IBOutlet weak var contentBox: NSBox!
    
    var currentPage: Page = .page1
    
    init() {
        super.init(window: nil)
        
        Bundle.main.loadNibNamed(NSNib.Name("Onboarding"), owner: self, topLevelObjects: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        goToPage(currentPage)
    }
    
    func goToPage(_ page: Page) {
        currentStep().removeFromSuperview()
        
        currentPage = page
        
        let step = currentStep()
        contentBox.addSubview(step)
    }
    
    func currentStep() -> NSView {
        switch currentPage {
        case .page1: return step1
        case .page2: return step2
        case .page3: return step3
        }
    }
}

class OnboardingStep1View: NSView {
    @IBOutlet weak var controller: OnboardingController!
    @IBOutlet weak var directoryPathControl: NSPathControl!
    @IBOutlet weak var pickButton: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    
    var unsubscribe: UnsubscribeFn?
    
    override func awakeFromNib() {
        pickButton.highlight(true)
        
        unsubscribe = store.subscribe { state in
            if state.directory != nil {
                self.directoryPathControl.url = state.directory
                self.nextButton.isEnabled = true
                self.nextButton.highlight(true)
            }
        }
    }
    
    deinit {
        unsubscribe?()
    }

    @IBAction func didPressPick(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        let path = NSString(string: store.state.directory?.path ?? "~").expandingTildeInPath
        openPanel.directoryURL = NSURL.fileURL(withPath: path, isDirectory: true)
        openPanel.canChooseFiles = false
        openPanel.resolvesAliases = true
        openPanel.begin { (result) in
            guard result == NSApplication.ModalResponse.OK else { return }
            Bookmark.url = openPanel.url
            store.dispatch(.setDirectory(openPanel.url))
        }
    }
    
    @IBAction func didPressNext(_ sender: Any) {
        controller.goToPage(.page2)
    }
}

class OnboardingStep2View: NSView {
    @IBOutlet weak var controller: OnboardingController!
    @IBOutlet weak var generateButton: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var checkmark: NSTextField!
    
    var unsubscribe: UnsubscribeFn?
    
    override func awakeFromNib() {
        unsubscribe = store.subscribe { state in
            self.nextButton.isEnabled = state.hasCert
            self.nextButton.isHighlighted = state.hasCert
            self.generateButton.isEnabled = !state.hasCert
            self.checkmark.isHidden = !state.hasCert
        }
    }
    
    deinit {
        unsubscribe?()
    }

    @IBAction func didPressGenerate(_ sender: Any) {
        JoofCertificate.generateCertsIfMissing { hasCert in
            store.dispatch(.hasCert(hasCert))
        }
    }
    
    @IBAction func didPressNext(_ sender: Any) {
        controller.goToPage(.page3)
    }
}

class OnboardingStep3View: NSView {
    @IBOutlet weak var controller: OnboardingController!

    @IBOutlet weak var safariButton: NSButton!
    @IBOutlet weak var firefoxButton: NSButton!
    @IBOutlet weak var chromeButton: NSButton!
    @IBOutlet weak var doneButton: NSButton!
    @IBOutlet weak var launchAtLoginCheckbox: NSButton!

    @IBAction func didPressSafari(_ sender: Any) {
        let identifier = "com.brnbw.Joof.extension"
        SFSafariApplication.showPreferencesForExtension(withIdentifier: identifier, completionHandler: nil)
    }

    @IBAction func didPressFirefox(_ sender: Any) {
        NSWorkspace.shared.openFile("https://joof.app/firefox", withApplication: "Firefox")
    }

    @IBAction func didPressChrome(_ sender: Any) {
        NSWorkspace.shared.openFile("https://joof.app/chrome", withApplication: "Google Chrome")
    }

    @IBAction func didPressDone(_ sender: Any) {
        controller.close()
        Defaults[.hasOnboarded] = true
        store.dispatch(.setIsOnboarding(false))
    }
    
    @IBAction func launchAtLoginPressed(_ sender: Any?) {
        let state = launchAtLoginCheckbox.state.rawValue == 1
        LaunchAtLogin.isEnabled = state
    }
}
