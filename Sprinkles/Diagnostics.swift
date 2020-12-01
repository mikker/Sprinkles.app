//
//  Diagnostics.swift
//  Moves
//
//  Created by Mikkel Malmberg on 19/03/2020.
//  Copyright © 2020 Brainbow. All rights reserved.
//

import Defaults
import Foundation
import Sentry

let dsn = "https://b0298bed5c364de2862c0760a881112b@sentry.io/1404238"

class Diagnostics {
  static var enabled = false

  static func enable() {
    SentrySDK.start { options in
      options.dsn = dsn
      options.debug = true
    }
    enabled = true
    SentrySDK.setUser(User(userId: Defaults[.userId]!))
    send("[diagnostics] Enable")
  }

  static func send(_ message: String, level: SentryLevel = .info) {
    if !enabled { return }

    let scope = Scope()
    scope.setLevel(level)
    SentrySDK.capture(message: message, scope: scope)
  }
}
