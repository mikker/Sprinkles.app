//
//  Diagnostics.swift
//  Sprinkles
//
//  Created by Mikkel Malmberg on 23/02/2020.
//  Copyright © 2020 Brainbow. All rights reserved.
//

import Foundation
import Sentry
import Defaults

class Diagnostics {
    static func enable() {
        do {
            Client.shared = try Client(dsn: "https://b0298bed5c364de2862c0760a881112b@sentry.io/1404238")
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
        }

        Client.shared?.user = User(userId: Defaults[.userId])
    }
    
    static func disable() {
        Client.shared = nil
    }
    
    static func send(_ message: String, level: SentrySeverity = .info) {
        guard Client.shared != nil else { return }
        
        let event = Event(level: level)
        event.message = message
        Client.shared?.send(event: event, completion: nil)
    }
}
