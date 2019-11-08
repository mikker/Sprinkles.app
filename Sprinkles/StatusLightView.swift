//
//  StatusLightView2.swift
//  Sprinkles
//
//  Created by Mikkel Malmberg on 18/01/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import Cocoa

class StatusLightView: NSView {
    var color: NSColor = NSColor.darkGray {
        didSet { needsDisplay = true }
    }

    override func draw(_ dirtyRect: NSRect) {

        let rect = NSRect(x: bounds.size.width / 2 - 6, y: bounds.size.height / 2 - 6, width: 12, height: 12)
        let circle = NSBezierPath(ovalIn: rect)
        color.setFill()
        circle.fill()
    }

    override func prepareForInterfaceBuilder() {
    }
}
