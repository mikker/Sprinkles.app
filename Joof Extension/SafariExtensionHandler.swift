//
//  SafariExtensionHandler.swift
//  Joof Extension
//
//  Created by Mikkel Malmberg on 16/01/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
     override func toolbarItemClicked(in window: SFSafariWindow) {
        window.openTab(with: URL(string: "https://localhost:3133")!, makeActiveIfPossible: true, completionHandler: nil)
    }

    override func validateToolbarItem(in window: SFSafariWindow,
                                      validationHandler: @escaping ((Bool, String) -> Void)) {
        validationHandler(true, "")
    }
}
