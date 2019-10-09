//
//  Certificate.swift
//  Joof
//
//  Created by Mikkel Malmberg on 14/02/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import Foundation
import Security
import Defaults

class JoofCertificate {
    static let dir = "\(NSHomeDirectory())/Certs"
    static let scriptPath = Bundle.main.path(forResource: "gen_cert", ofType: "sh")!
    static let keyPath = "\(dir)/joof.key"
    static let certPath = "\(dir)/joof.crt"

    static func generateCertsIfMissing(_ callback: @escaping (Bool) -> Void) {
        let certAndKey = FileManager.default.fileExists(atPath: certPath) &&
            FileManager.default.fileExists(atPath: keyPath)

        if certAndKey {
            callback(true)
        } else {
            let task = Process()
            task.launchPath = JoofCertificate.scriptPath
            task.arguments = [Bundle.main.resourcePath!, NSHomeDirectory(), Defaults[.userId]]

            DispatchQueue.main.async {
                task.launch()
                task.waitUntilExit()

                self.acceptCert()

                callback(task.terminationStatus == 0)
            }
        }
    }

    static func acceptCert() {
        let data = NSData(contentsOf: URL(fileURLWithPath: "Certs/rootCA.der"))!
        var err: OSStatus = noErr

        let rootCert = SecCertificateCreateWithData(nil, data)!
        let dict = NSDictionary.init(
            objects: [kSecClassCertificate, rootCert],
            forKeys: [kSecClass as! NSCopying, kSecValueRef as! NSCopying])

        err = SecItemAdd(dict, nil)
        print(SecCopyErrorMessageString(err, nil)!)

        var status: OSStatus = noErr
        status = SecTrustSettingsSetTrustSettings(rootCert, SecTrustSettingsDomain.user, nil)
        print(SecCopyErrorMessageString(status, nil)!)
    }

    static func destroy() {
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: dir))
        } catch {
            print(error)
        }
    }
}
