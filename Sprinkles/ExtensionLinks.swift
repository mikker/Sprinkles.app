//
//  ExtensionLinks.swift
//  Sprinkles
//
//  Created by Mikkel Malmberg on 16/12/2020.
//  Copyright © 2020 Brainbow. All rights reserved.
//

import Foundation
import SafariServices

class ExtensionLinks {
  static func safari() {
    SFSafariApplication.showPreferencesForExtension(
      withIdentifier: "com.brnbw.Sprinkles.Sprinkles-Extension"
    ) { err in
      if let err = err { print(err) }
    }
  }

  static func firefox() {
    if !NSWorkspace.shared.openFile("https://getsprinkles.app/firefox", withApplication: "Firefox")
    {
      missingAppAlert(text: "You don't seem to have Firefox installed?")
    }
  }

  static func chrome() {
    if !NSWorkspace.shared.openFile(
      "https://getsprinkles.app/chrome", withApplication: "Google Chrome")
    {
      missingAppAlert(text: "You don't seem to have Google Chrome installed?")
    }
  }

  static private func missingAppAlert(text: String) {
    let alert = NSAlert()
    alert.messageText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.runModal()
  }
}
