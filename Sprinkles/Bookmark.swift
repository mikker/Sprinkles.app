//
//  DirectoryPermissions.swift
//  Sprinkles
//
//  Created by Mikkel Malmberg on 18/01/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import Cocoa

public class Bookmark {
  static let defaultScriptsDirectoryPath = NSHomeDirectory() + "/Scripts"

  typealias Permissions = [URL: Data]

  public static var url: URL {
    get { return instance.url }
    set(url) { instance.url = url }
  }

  private static let instance = Bookmark()

  private var url: URL {
    get {
      readFromDisk()
    }

    set(url) {
      saveToDisk(url)
    }
  }

  private func fileURL() -> URL {
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
    return url.appendingPathComponent("Bookmark.dict")
  }

  private func hasBookmark() -> Bool {
    return FileManager.default.fileExists(atPath: fileURL().path)
  }

  private func readFromDisk() -> URL {
    guard hasBookmark() else { return ensureDefaultDir() }
    guard let dir = readBookmark() else { return ensureDefaultDir() }
    return dir
  }

  private func readBookmark() -> URL? {
    var isStale = ObjCBool(false)
    let restored: URL?

    do {
      let fileData = try Data(contentsOf: fileURL())
      guard
        let permissions =
          try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as? Permissions
      else { return nil }
      guard let (_, data) = permissions.first else { return ensureDefaultDir() }
      restored =
        try NSURL.init(
          resolvingBookmarkData: data,
          options: .withSecurityScope,
          relativeTo: nil, bookmarkDataIsStale: &isStale) as URL
    } catch {
      print(error)
      return nil
    }

    guard !isStale.boolValue else { return nil }
    guard restored != nil else { return nil }
    guard restored?.startAccessingSecurityScopedResource() ?? false else { return nil }

    return restored
  }

  private func ensureDefaultDir() -> URL {
    let url = URL(fileURLWithPath: Bookmark.defaultScriptsDirectoryPath)

    if FileManager.default.fileExists(atPath: url.path) { return url }

    do {
      try FileManager.default.createDirectory(
        at: url, withIntermediateDirectories: true, attributes: nil)
    } catch {
      fatalError(error.localizedDescription)
    }

    self.url = url

    return url
  }

  private func saveToDisk(_ url: URL) {
    var url = url
    let bookmarkData: Data

    do {
      url.resolveSymlinksInPath()
      bookmarkData = try url.bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil, relativeTo: nil)
    } catch {
      fatalError(error.localizedDescription)
    }

    let permission = [url: bookmarkData]

    do {
      let data = try NSKeyedArchiver.archivedData(
        withRootObject: permission, requiringSecureCoding: false)
      try data.write(to: fileURL())
    } catch {
      fatalError(error.localizedDescription)
    }
  }
}
