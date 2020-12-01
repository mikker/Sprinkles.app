//
//  Certificate.swift
//  Sprinkles
//
//  Created by Mikkel Malmberg on 14/02/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import Defaults
import Foundation
import Security

class SprinklesCertificate {
  static let dir = "\(NSHomeDirectory())/Certs"
  static let scriptPath = Bundle.main.path(forResource: "gen_cert", ofType: "sh")!
  static let caPath = "\(dir)/ca.der"
  static let keyPath = "\(dir)/key.pem"
  static let certPath = "\(dir)/cert.pem"
  static let p12Path = "\(dir)/identity.p12"

  static var exists: Bool {
    return FileManager.default.fileExists(atPath: caPath)
      && FileManager.default.fileExists(atPath: keyPath)
      && FileManager.default.fileExists(atPath: certPath)
      && FileManager.default.fileExists(atPath: p12Path)
  }

  static func generateCertsIfMissing(_ callback: @escaping (Bool) -> Void) {
    if exists {
      callback(true)
    } else {
      let task = Process()
      task.launchPath = SprinklesCertificate.scriptPath
      task.arguments = [Bundle.main.resourcePath!, Defaults[.userId]!]

      DispatchQueue.main.async {
        task.launch()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
          callback(false)
        }

        self.acceptCert()

        callback(true)
      }
    }
  }

  static func acceptCert() {
    let data = NSData(contentsOf: URL(fileURLWithPath: caPath))!
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
