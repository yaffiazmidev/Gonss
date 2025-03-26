//
//  KKLogFile.swift
//  KipasKipasShared
//
//  Created by koanba on 30/10/23.
//

import Foundation
import FileLogging
import Logging
//import FileLogging
//import Logging



public class KKLogFile {
    
    private static var _instance: KKLogFile?
    private static let lock = NSLock()

    
    private init(){
        setupLog()
    }
    
    public enum logLevel {
      case info, error
    }

    public static var instance: KKLogFile {
        if _instance == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _instance == nil {
                _instance = KKLogFile()
            }
        }
        return _instance!
    }
    

    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }

    func setupLog(){}
    
    let logFile = "kklog.log"
    
    var logFileString = ""
    
    public func log(label: String, message: String, level: logLevel = .info){
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            print(dateFormatter.string(from: Date()),"*** KKlog:", label, message)
            if(logFileString == ""){
                logFileString = getDocumentsDirectory().appendingPathComponent(logFile)
            }
            
            if let logURL = URL(string: logFileString) {
                let logger = try FileLogging.logger(label: label, localFile: logURL)
                let myLogMessage: Logger.Message = "\(message)"
                
                if(level == .error){
                    logger.error(myLogMessage)
                } else {
                    logger.info(myLogMessage)
                }

            }
            
        } catch {
            print("KKLogFile.info error \(error.localizedDescription)")
        }
    }



}
