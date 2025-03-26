//
//  DownloadManager.swift
//  KipasKipas
//
//  Created by Zein Rezky Chandra on 09/08/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

class DownloadManager: NSObject {
    
    fileprivate var operations = [Int: DownloadOperation]()
    
    private let queue: OperationQueue = {
        let _queue = OperationQueue()
        _queue.name = "download"
        _queue.maxConcurrentOperationCount = 3
        
        return _queue
    }()
    
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    @discardableResult
    func queueDownload(_ url: URL) -> DownloadOperation {
        if isFileExists(url: url) {
            print("masuk sini \(url)")
            let operation = DownloadOperation(session: session, url: url)
            print(operation.task.taskIdentifier)
            operations[operation.task.taskIdentifier] = operation
            return operation
        } else {
            let operation = DownloadOperation(session: session, url: url)
            operations[operation.task.taskIdentifier] = operation
            print("\(operation.task.taskIdentifier) TASK IDENTIFIER")
            queue.addOperation(operation)
            print("\(queue.progress) PROGRESSS")
            return operation
        }
    }
    
    func cancelAll() {
        queue.cancelAllOperations()
    }
    
    func isFileExists(url: URL) -> Bool {
        guard let docFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let fileName = url.lastPathComponent
        let fileURL = docFolderURL.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            print("Task Cancellll")
            return true
        }
        return false
    }
    
}

// MARK: - URLSessionDownloadDelegate methods

extension DownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        operations[downloadTask.taskIdentifier]?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        operations[downloadTask.taskIdentifier]?.urlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
}

// MARK: - URLSessionTaskDelegate methods

extension DownloadManager: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)  {
        let key = task.taskIdentifier
        operations[key]?.urlSession(session, task: task, didCompleteWithError: error)
        operations.removeValue(forKey: key)
    }
    
}

class DownloadOperation : AsynchronousOperation {
    let task: URLSessionTask
    let url: URL
    
    init(session: URLSession, url: URL) {
        task = session.downloadTask(with: url)
        self.url = url
        super.init()
    }
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
    
    override func main() {
        task.resume()
    }
}

// MARK: - NSURLSessionDownloadDelegate methods

extension DownloadOperation: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard
            let httpResponse = downloadTask.response as? HTTPURLResponse,
            200..<300 ~= httpResponse.statusCode
        else {
            return
        }

        do {
            guard let docFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let fileName = self.url.lastPathComponent
            let fileURL = docFolderURL.appendingPathComponent(fileName)
            
            let manager = FileManager.default
            try manager.moveItem(at: location, to: fileURL)
            print("download dan pindahin ke \(fileURL)")
        } catch {
            print(error)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
//        print("\(downloadTask.originalRequest!.url!.absoluteString) \(progress)")
    }
}

// MARK: - URLSessionTaskDelegate methods

extension DownloadOperation: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)  {
        defer { finish() }
        
        if let error = error {
            print(error)
            return
        }
    }
    
}
