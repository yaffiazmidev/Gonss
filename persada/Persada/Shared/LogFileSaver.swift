//
//  LogFileSaver.swift
//  KipasKipas
//
//  Created by PT.Koanba on 01/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class LogFileSaver {
    
    private let fileName: String
    
    public init(fileName: String) {
        self.fileName = fileName
    }
    
    func saveLog(message: String) {
        do {
            try message.write(to: getDocumentURL(), atomically: true, encoding: .utf8)
        } catch {
            print("Failed saveLog \(message) to \(fileName).txt with error: \(error)")
        }

    }
    
    func readSavedLog() -> String? {
        
        do {
            let text = try String(contentsOf: getDocumentURL(), encoding: .utf8)
            return text
        } catch {
            print("Failed readSavedLog from \(fileName).txt with error: \(error)")
            return nil
        }
    }
    
    private func getDocumentURL() -> URL {
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        return fileURL
    }
    
}
