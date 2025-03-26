//
//  NetworkMonitor.swift
//  KipasKipasNetworking
//
//  Created by Rahmat Trinanda Pramudya Amar on 31/08/23.
//

import Network

public protocol NetworkMonitorDelegate: AnyObject {
    func statusDidChange(status: NetworkMonitorStatus)
}

public enum NetworkMonitorStatus {
    case requiresConnection
    case satisfied
    case unsatisfied
    case undefined
    
    static func fromPath(_ status: NWPath.Status) -> NetworkMonitorStatus {
        switch(status) {
        case .requiresConnection:
            return .requiresConnection
        case .satisfied:
            return .satisfied
        case .unsatisfied:
            return .unsatisfied
        @unknown default:
            return .undefined
        }
    }
}

public class NetworkMonitor {
    struct NetworkChangeObservation {
        weak var delegate: NetworkMonitorDelegate?
    }
    
    private var monitor = NWPathMonitor()
    public static let instance = NetworkMonitor()
    private var observations = [ObjectIdentifier: NetworkChangeObservation]()
    public var currentStatus: NetworkMonitorStatus {
        get {
            return NetworkMonitorStatus.fromPath(monitor.currentPath.status)
        }
    }
    
    private init() {
        monitor.pathUpdateHandler = { [unowned self] path in
            for (id, observations) in self.observations {
                
                //If any observer is nil, remove it from the list of observers
                guard let observer = observations.delegate else {
                    self.observations.removeValue(forKey: id)
                    continue
                }
                
                DispatchQueue.main.async(execute: {
                    observer.statusDidChange(status: NetworkMonitorStatus.fromPath(path.status))
                })
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
}

// MARK: - Observer
public extension NetworkMonitor {
    func addObserver(observer: NetworkMonitorDelegate) {
        let id = ObjectIdentifier(observer)
        observations[id] = NetworkChangeObservation(delegate: observer)
    }
    
    func removeObserver(observer: NetworkMonitorDelegate) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}
