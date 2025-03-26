//
//  NetworkSpeedMonitor.swift
//  KipasKipasNetworking
//
//  Created by Rahmat Trinanda Pramudya Amar on 31/08/23.
//

import Foundation

public protocol NetworkSpeedMonitorDelegate: AnyObject {
    func speedDidChange(speed: NetworkSpeedMonitorStatus)
}

public enum NetworkSpeedMonitorStatus: String {
    case slow
    case fast
    case hostUnreachable
    
    static func getFromNetworkMonitor() -> NetworkSpeedMonitorStatus {
        return NetworkSpeedMonitorStatus.fromNetworkMonitor(NetworkMonitor.instance.currentStatus)
    }
    
    static func fromNetworkMonitor(_ status: NetworkMonitorStatus) -> NetworkSpeedMonitorStatus {
        if status == .satisfied {
            return .fast
        } else if status == .unsatisfied {
            return .slow
        } else {
            return .hostUnreachable
        }
    }
}

public class NetworkSpeedMonitor {
    
    public static let instance: NetworkSpeedMonitor = NetworkSpeedMonitor()
    
    private(set) var _currentNetworkSpeed: NetworkSpeedMonitorStatus = NetworkSpeedMonitorStatus.getFromNetworkMonitor()
    
    /// Delegate called when the network speed changes
    public weak var delegate: NetworkSpeedMonitorDelegate?
    
    private var testURL: URL = URL(string: "https://kipaskipas.com/")!
    
    private var timerForSpeedTest: Timer?
    private let updateInterval: TimeInterval = 5
    
    //private let maxSecondFastParam: Double = 2.5
    private let maxSecondFastParam: Double = 0.5
    
    private let urlSession: URLSession
    
    private init() {
        let urlSessionConfig = URLSessionConfiguration.ephemeral
        urlSessionConfig.timeoutIntervalForRequest = updateInterval - 1.0 // Timeout
        urlSessionConfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.urlSession = URLSession(configuration: urlSessionConfig)
        self.addPlayerObserver()
    }
    
    deinit {
        print("PE10943 NetworkSpeedMonitor deinit")
        stop()
        removePlayerObserver()
    }
    
    public func currentNetworkSpeed() -> NetworkSpeedMonitorStatus {
        return _currentNetworkSpeed
    }
}

// MARK: - Main method, hit url
public extension NetworkSpeedMonitor {
    /// Starts the check
    func start() {
        timerForSpeedTest = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(testForSpeed), userInfo: nil, repeats: true)
    }
    
    /// Starts the check with specific url
    func start(with url: URL) {
        self.testURL = url
        timerForSpeedTest = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(testForSpeed), userInfo: nil, repeats: true)
    }
    
    /// Stops the check
    func stop(){
        timerForSpeedTest?.invalidate()
        timerForSpeedTest = nil
    }
    
    @objc private func testForSpeed() {
        print("PE10943 NetworkSpeedMonitor", "starting test with url:", testURL.absoluteString)
        Task {
            let startTime = Date()
            
            do {
                _ = try await urlSession.data(for: URLRequest(url: testURL))
                let endTime = Date()
                
                let duration = abs(endTime.timeIntervalSince(startTime))
                
                print("PE10943 duration:", duration)
                
                switch duration {
                    case 0.0...maxSecondFastParam:
                        print("PE10943 NetworkSpeedMonitor", "result: fast")
                        _currentNetworkSpeed = .fast
                        delegate?.speedDidChange(speed: .fast)
                    default:
                        print("PE10943 NetworkSpeedMonitor", "result: slow")
                        _currentNetworkSpeed = .slow
                        delegate?.speedDidChange(speed: .slow)
                }
            } catch let error {
                print("PE10943 NetworkSpeedMonitor", "result: hostUnreachable")
                guard let urlError = error as? URLError else {
                    return
                }
                
                switch urlError.code {
                case    .cannotConnectToHost,
                        .cannotFindHost,
                        .clientCertificateRejected,
                        .dnsLookupFailed,
                        .networkConnectionLost,
                        .notConnectedToInternet,
                        .resourceUnavailable,
                        .serverCertificateHasBadDate,
                        .serverCertificateHasUnknownRoot,
                        .serverCertificateNotYetValid,
                        .serverCertificateUntrusted,
                        .timedOut:
                    _currentNetworkSpeed = .hostUnreachable
                    delegate?.speedDidChange(speed: .hostUnreachable)
                default:
                    break
                }
            }
        }
    }
}

// MARK: For handling speed source from player
public extension NetworkSpeedMonitor {
    private func addPlayerObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveSpeedFromPlayer(notification:)), name: Notification.Name("com.koanba.kipaskipas.mobile.NetworkSpeedMonitor.player"), object: nil)
    }
    
    @objc private func didReceiveSpeedFromPlayer(notification: Notification) {
        if let dict = notification.object as? NSDictionary?, let speed = dict?["speed"] as? Int {
            guard speed > 0 else { return }
            print("PE10953 NetworkSpeedMonitor", "didReceiveSpeedFromPlayer", "speed:", speed, "kbps")
            if speed <= 100 {
                _currentNetworkSpeed = .slow
                delegate?.speedDidChange(speed: .slow)
                print("PE10953 NetworkSpeedMonitor", "didReceiveSpeedFromPlayer", "result:", _currentNetworkSpeed)
                return
            }
            
            
            _currentNetworkSpeed = .fast
            delegate?.speedDidChange(speed: .fast)
            print("PE10953 NetworkSpeedMonitor", "didReceiveSpeedFromPlayer", "result:", _currentNetworkSpeed)
        }
    }
    
    private func removePlayerObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}
