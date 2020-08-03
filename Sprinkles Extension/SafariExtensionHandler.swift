//
//  SafariExtensionHandler.swift
//  Sprinkles Extension
//
//  Created by Mikkel Malmberg on 16/01/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import SafariServices

enum State {
  case loading
  case requestFailed
  case evalFailed
  case unknown
  case ok
}

class SafariExtensionHandler: SFSafariExtensionHandler {
  var state: State = .ok

  override func page(_ page: SFSafariPage, willNavigateTo url: URL?) {
    state = .loading
  }

  override func toolbarItemClicked(in window: SFSafariWindow) {
    window.openTab(
      with: URL(string: "https://localhost:3133")!, makeActiveIfPossible: true,
      completionHandler: nil)
  }

  //  override func messageReceived(
  //    withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]? = nil
  //  ) {
  //    // If we've already failed at something, we ignore new messages
  //    if state == .requestFailed || state == .evalFailed { return }
  //
  //    state = stateFromMessage(messageName)
  //    updateToolbarItemFor(page: page)
  //  }
  //
  //  private func stateFromMessage(_ messageName: String) -> State {
  //    switch messageName {
  //    case "ok": return .ok
  //    case "request-failed": return .requestFailed
  //    case "eval-failed": return .evalFailed
  //    default: return .unknown
  //    }
  //  }
  //  private func updateToolbarItemFor(page: SFSafariPage) {
  //    itemFor(page: page) { (maybeItem) in
  //      guard let item = maybeItem else { return }
  //
  //      item.setLabel(nil)
  //      item.setEnabled(true)
  //      item.setBadgeText(nil)
  //
  //      switch self.state {
  //      case .requestFailed:
  //        item.setEnabled(false)
  //        item.setBadgeText("!")
  //        item.setLabel("Sprinkles failed to request scripts. Server down?")
  //        break
  //      case .evalFailed:
  //        item.setBadgeText("!")
  //        item.setLabel("Sprinkles failed running your scripts. See console for more.")
  //        break
  //      case .unknown:
  //        item.setBadgeText("?")
  //      default: break
  //      }
  //    }
  //  }

  //  private func itemFor(page: SFSafariPage, handler: @escaping (SFSafariToolbarItem?) -> Void) {
  //    page.getContainingTab { (tab) in
  //      tab.getContainingWindow { (window) in
  //        window?.getToolbarItem(completionHandler: handler)
  //      }
  //    }
  //  }
}
