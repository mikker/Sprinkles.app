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
    if let url = URL(string: "https://getsprinkles.app/firefox") {
      if NSWorkspace.shared.urlForApplication(withBundleIdentifier: "org.mozilla.firefox") != nil {
        NSWorkspace.shared.open(url)
      } else {
        missingAppAlert(
          text:
            "You don't seem to have Firefox installed? Try https://getsprinkles.app/firefox manually"
        )
      }
    }
  }

  static func chrome() {
    if let url = URL(string: "https://getsprinkles.app/chrome") {
      if NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") != nil {
        NSWorkspace.shared.open(url)
      } else {
        missingAppAlert(
          text:
            "You don't seem to have Google Chrome installed? Try https://getsprinkles.app/chrome manually"
        )
      }
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
