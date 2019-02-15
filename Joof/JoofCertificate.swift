//
//  Certificate.swift
//  Joof
//
//  Created by Mikkel Malmberg on 14/02/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import Foundation

class JoofCertificate {
    static let keyPath = "\(NSHomeDirectory())/joof.key"
    static let certPath = "\(NSHomeDirectory())/joof.crt"

    static func generateCertsIfMissing(_ callback: @escaping (Bool) -> Void) {
        let certAndKey = FileManager.default.fileExists(atPath: certPath) &&
            FileManager.default.fileExists(atPath: keyPath)

        if certAndKey {
            callback(true)
        } else {
            let task = Process()
            task.launchPath = "/usr/bin/openssl"
            task.arguments = [
                "req", "-new", "-newkey", "rsa:2048", "-days", "3652", "-nodes", "-x509",
                "-subj", "/C=DK/ST=Denmark/O=Brainbow/CN=localhost",
                "-keyout", "joof.key", "-out", "joof.crt"
            ]
            task.launch()

            DispatchQueue.main.async {
                task.waitUntilExit()

                callback(task.terminationStatus == 0)
            }
        }
    }
}
