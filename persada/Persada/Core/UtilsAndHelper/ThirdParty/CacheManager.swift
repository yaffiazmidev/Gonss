//
//  CacheManager.swift
//  KipasKipas
//
//  Created by Adebayo Adesokan on 01.06.2021.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
public enum Result<T> {
    case success(T)
    case failure(NSError)
}

class CacheManager {

    static let shared = CacheManager()

    private let fileManager = FileManager.default

    private lazy var mainDirectoryUrl: URL = {

        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return documentsUrl
    }()

    func getFileWith(stringUrl: String, completionHandler: @escaping (Result<URL>) -> Void ) {


        let file = directoryFor(stringUrl: stringUrl)

        //return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: file.path)  else {
            completionHandler(Result.success(file))
            return
        }

        DispatchQueue.global().async {

            if let videoData = NSData(contentsOf: URL(string: stringUrl)!) {
                videoData.write(to: file, atomically: true)

                DispatchQueue.main.async {
                    completionHandler(Result.success(file))
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(Result.failure(NSError.init()))
                }
            }
        }
    }

    private func directoryFor(stringUrl: String) -> URL {

        let fileURL = URL(string: stringUrl)!.lastPathComponent

        let file = self.mainDirectoryUrl.appendingPathComponent(fileURL)

        return file
    }
}

class CustomCache {
    let fManager: FilesManager
//    let userDefaults: UserDefaults
    init() {
        self.fManager = FilesManager()
    }
    func set(key: NSString, _ value: NSData?) {
        if let val = value {
            fManager.writeFile(fileName: key as String, data: val)
        } else {
            fManager.writeFile(fileName: key as String, data: NSData())
        }
        //fManager.writeFile(fileName: key as String, data: NSData())
//        userDefaults.setValue(value, forKey: key as String)
//        userDefaults.synchronize()
    }

    func get(_ with: NSString) -> NSData? {
        return fManager.getFile(fileName: with as String)
    }
}

class FilesManager {
    let fileManager: FileManager
    let tempDir: String
    init() {
        fileManager = FileManager()
        tempDir = NSTemporaryDirectory()
    }

    func checkDirectory(fileName: String) -> Bool {
        do {
            let filesInDirectory = try fileManager.contentsOfDirectory(atPath: tempDir)
            let files = filesInDirectory
            if files.count > 0 {
                if files.first == fileName {
                    return true
                } else {
                    return false
                }
            }
        } catch let error as NSError {
            print(error)
        }
        return false
    }

    func writeFile(fileName: String, data: NSData) {

        let path = (tempDir as NSString).appendingPathComponent(fileName)
//        print("HHHHHHH: \(path)")

        do {
            try data.write(toFile: path)
//            try contentsOfFile.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print("\(error)")
        }
    }

    func getFile(fileName: String) -> NSData? {
        let path = (tempDir as NSString).appendingPathComponent(fileName)
        let data = NSData(contentsOfFile: path)
        //print(data)
        return data
    }

}
