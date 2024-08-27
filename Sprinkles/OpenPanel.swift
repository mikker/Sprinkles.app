import Cocoa

class OpenPanel {
  static func pick(_ cb: @escaping (URL?) -> Void) {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = true
    openPanel.canCreateDirectories = true
    openPanel.directoryURL = store.state.directory
    openPanel.canChooseFiles = false
    openPanel.resolvesAliases = true
    openPanel.prompt = "Pick directory"
    openPanel.begin { (result) in
      guard result == NSApplication.ModalResponse.OK else { return cb(nil) }
      cb(openPanel.url)
    }
  }
}
