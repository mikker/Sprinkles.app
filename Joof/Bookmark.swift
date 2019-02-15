//
//  DirectoryPermissions.swift
//  Joof
//
//  Created by Mikkel Malmberg on 18/01/2019.
//  Copyright © 2019 Brainbow. All rights reserved.
//

import Cocoa

public class Bookmark {
    typealias Permissions = [URL: Data]

    public static var url: URL? {
        get { return instance.url }
        set(url) { instance.url = url }
    }

    private static let instance = Bookmark()

    private var url: URL? {
        get {
            return readFromDisk()
        }

        set(url) {
            guard url != nil else { return }
            saveToDisk(url!)
        }
    }

    private func fileURL() -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        return url.appendingPathComponent("Bookmark.dict")
    }

    private func readFromDisk() -> URL? {
        guard FileManager.default.fileExists(atPath: fileURL().path) else { return nil }
        var isStale = ObjCBool(false)
        let restored: URL?

        do {
            let fileData = try Data(contentsOf: fileURL())
            guard let permissions =
                try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as? Permissions else { return nil }
            guard let (_, data) = permissions.first else { return nil }
            restored = try NSURL.init(resolvingBookmarkData: data,
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

    private func saveToDisk(_ url: URL) {
        var url = url
        let bookmarkData: Data

        do {
            url.resolveSymlinksInPath()
            bookmarkData = try url.bookmarkData(options: .withSecurityScope,
                                                includingResourceValuesForKeys: nil, relativeTo: nil)
        } catch {
            fatalError(error.localizedDescription)
       }

        let permission = [url: bookmarkData]

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: permission, requiringSecureCoding: false)
            try data.write(to: fileURL())
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
