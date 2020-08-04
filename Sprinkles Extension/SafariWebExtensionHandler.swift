//
//  SafariWebExtensionHandler.swift
//  Sprinkles Extension
//
//  Created by Mikkel Malmberg on 03/08/2020.
//  Copyright © 2020 Brainbow. All rights reserved.
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
  func beginRequest(with context: NSExtensionContext) {
    context.completeRequest(returningItems: nil, completionHandler: nil)
  }
}
