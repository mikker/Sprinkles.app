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

class Diagnostics {
  static func enable() {
    do {
      Client.shared = try Client(dsn: "https://b0298bed5c364de2862c0760a881112b@sentry.io/1404238")
      try Client.shared?.startCrashHandler()

      Client.shared?.user = User(userId: Defaults[.userId])
    } catch let error {
      print("\(error)")
    }

    send("[diagnostics] Enable")
  }

  static func send(_ message: String, level: SentrySeverity = .info) {
    guard let cli = Client.shared else { return }

    let event = Event(level: level)
    event.message = message

    cli.send(event: event, completion: nil)
  }
}
