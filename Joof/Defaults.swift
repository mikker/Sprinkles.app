//
//  Defaults.swift
//  Joof
//
//  Created by Mikkel Malmberg on 20/01/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import Cocoa
import Defaults

extension Defaults.Keys {
    static let userId = Key<String>("userId", default: UUID().uuidString)
}
