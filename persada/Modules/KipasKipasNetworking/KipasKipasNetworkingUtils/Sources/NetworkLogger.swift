//
//  NetworkLogger.swift
//  KipasKipasNetworkingUtils
//
//  Created by Rahmat Trinanda Pramudya Amar on 12/03/24.
//

import Foundation
import Network

public protocol NetworkLoggerDelegate {
    func vpnStateDidChanged(_ enable: Bool)
    func proxyStateDidChanged(_ enable: Bool)
    func interfaceStateDidChanged(_ type: NetworkLogger.InterfaceType)
}

public class NetworkLogger {
    
    private static var _instance: NetworkLogger?
    private static let lock = NSLock()
    
    private var logId = "NetworkLogger"
    private var isRunning: Bool = false
    public var delegate: NetworkLoggerDelegate?
    public var options: NetworkLogger.Options!
    
    // MARK: State
    private var vpnEnabled: Bool = false
    private var proxyEnabled: Bool = false
    private var interfaceType: InterfaceType = .unknowned
    
    public struct Options {
        
        public struct Listener {
            public var enableVPN: Bool
            public var enableProxy: Bool
            public var enableInterface: Bool
            
            public static func enable() -> Listener {
                return Listener(enableVPN: true, enableProxy: true, enableInterface: true)
            }
            
            fileprivate func isEnabled() -> Bool {
                return enableVPN || enableProxy || enableInterface
            }
        }
        
        public var delay: Int = 2
        public var listener: Listener = .enable()
        
        public init(delay: Int = 2, listener: Listener = .enable()) {
            self.delay = delay
            self.listener = listener
        }
        
        public static func create() -> Options {
            return Options(delay: 2, listener: .enable())
        }
    }
    
    public enum InterfaceType {
        case wifi
        case cellular
        case wiredEthernet
        case loopback
        case other
        case unknowned
    }
    
    public static var instance: NetworkLogger {
        if _instance == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _instance == nil {
                _instance = NetworkLogger()
                _instance?.options = .create()
            }
        }
        return _instance!
    }
    
    private init() {
        print(logId, "Instance Created")
    }
    
}

// MARK: - Public Func
public extension NetworkLogger {
    func startListen() {
        isRunning = true
        runDispatch()
        print(logId, "Start Listening")
    }
    
    func stopListen() {
        isRunning = false
        print(logId, "Stop Listening")
    }
}

// MARK: - Main Logic
private extension NetworkLogger {
    func runDispatch() {
        guard isRunning, options.listener.isEnabled() else {
            print("Runner canceled. isRunning:", isRunning, "isEnabled:", options.listener.isEnabled())
            return
        }
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(options.delay)) {
            self.checkVPN()
            self.checkProxy()
            self.checkInterface()
            // start logic here
            
            self.runDispatch()
        }
    }
    
    func checkVPN() {
        guard options.listener.enableVPN else { return } // Is function enabled
        
        let state = isVpnActive()
        guard vpnEnabled != state else { return } // Is value changed
        
        vpnEnabled = state
        delegate?.vpnStateDidChanged(vpnEnabled)
        print(self.logId, "VPN State is changed. vpnEnabled:", vpnEnabled)
    }
    
    func checkProxy() {
        guard options.listener.enableProxy else { return }
        
        let state = isProxyConfigured()
        guard proxyEnabled != state else { return }
        
        proxyEnabled = state
        delegate?.proxyStateDidChanged(proxyEnabled)
        print(self.logId, "Proxy State is changed. proxyEnabled:", proxyEnabled)
    }
    
    func checkInterface() {
        guard options.listener.enableInterface else { return }
        
        networkInterface { type in
            guard self.interfaceType != type else { return }
            
            self.interfaceType = type
            self.delegate?.interfaceStateDidChanged(self.interfaceType)
            print(self.logId, "Interface Type is changed. interfaceType:", self.interfaceType)
        }
    }
}

// MARK: - Checker Function
private extension NetworkLogger {
    func isVpnActive() -> Bool {
        let vpnProtocolsKeysIdentifiers = ["tap", "tun", "ppp", "ipsec", "utun"]
        
        guard let cfDict = CFNetworkCopySystemProxySettings() else { return false }
        let nsDict = cfDict.takeRetainedValue() as NSDictionary
        guard let keys = nsDict["__SCOPED__"] as? NSDictionary,
              let allKeys = keys.allKeys as? [String] else { return false }
        
        // Checking for tunneling protocols in the keys
        for key in allKeys {
            for protocolId in vpnProtocolsKeysIdentifiers
            where key.starts(with: protocolId) {
                // I use start(with:), so I can cover also `ipsec4`, `ppp0`, `utun0` etc...
                return true
            }
        }
        return false
    }
    
    func isProxyConfigured() -> Bool {
        if let proxies = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() as? [AnyHashable: Any],
           let httpProxy = proxies[kCFNetworkProxiesHTTPEnable] as? Bool,
           httpProxy {
            return true
        }
        return false
    }
    
    
    func networkInterface(completion: @escaping (InterfaceType) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkLogger.interface")
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            if path.usesInterfaceType(.wifi) {
                completion(.wifi)
                return
            }
            
            if path.usesInterfaceType(.cellular) {
                completion(.cellular)
                return
            }
            
            if path.usesInterfaceType(.wiredEthernet) {
                completion(.wiredEthernet)
                return
            }
            
            if path.usesInterfaceType(.loopback) {
                completion(.loopback)
                return
            }
            
            if path.usesInterfaceType(.other) {
                completion(.other)
                return
            }
            
            completion(.unknowned)
        }
        monitor.cancel()
    }
}
