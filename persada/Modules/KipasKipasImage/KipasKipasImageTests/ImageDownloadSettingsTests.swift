import KipasKipasImage
import XCTest

final class ImageDownloadSettingsTests: XCTestCase {
    
    override class func setUp() {
        ImageURLSession.observe()
    }
    
    override func tearDown() async throws {
        ImageDownloadSettings.requestSettings.cacheSettings = nil
    }
    
    func test_changeRequestTimeoutSeconds_withSameSettings_doesNotUpdateURLSession() {
        ImageDownloadSettings.requestSettings.requestTimeoutSeconds = 12
        let previousSession = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.requestTimeoutSeconds = 12
        let newSession = ImageURLSession.createSession()
        
        XCTAssertEqual(previousSession.configuration.timeoutIntervalForRequest, 12)
        XCTAssertEqual(newSession.configuration.timeoutIntervalForRequest, 12)
        XCTAssertIdentical(previousSession, newSession)
    }
    
    func test_changeRequestTimeoutSeconds_withDifferentSettings_updateURLSession() {
        ImageDownloadSettings.requestSettings.requestTimeoutSeconds = 12
        let previousSession = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.requestTimeoutSeconds = 13
        let newSession = ImageURLSession.createSession()
        
        XCTAssertEqual(previousSession.configuration.timeoutIntervalForRequest, 12)
        XCTAssertEqual(newSession.configuration.timeoutIntervalForRequest, 13)
        XCTAssertNotIdentical(previousSession, newSession)
    }
    
    func test_changeMaximumSimultaneousDownloads_withSameSettings_doesNotUpdateURLSession() {
        ImageDownloadSettings.requestSettings.maximumSimultaneousDownloads = 5
        let previousSession = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.maximumSimultaneousDownloads = 5
        let newSession = ImageURLSession.createSession()
        
        XCTAssertEqual(previousSession.configuration.httpMaximumConnectionsPerHost, 5)
        XCTAssertEqual(newSession.configuration.httpMaximumConnectionsPerHost, 5)
        XCTAssertIdentical(previousSession, newSession)
    }
    
    func test_changeMaximumSimultaneousDownloads_withDifferentSettings_updateURLSession() {
        ImageDownloadSettings.requestSettings.maximumSimultaneousDownloads = 5
        let previousSession = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.maximumSimultaneousDownloads = 8
        let newSession = ImageURLSession.createSession()
        
        XCTAssertEqual(previousSession.configuration.httpMaximumConnectionsPerHost, 5)
        XCTAssertEqual(newSession.configuration.httpMaximumConnectionsPerHost, 8)
        XCTAssertNotIdentical(previousSession, newSession)
    }
    
    func test_changeCacheSettings() {
        let sessionWithoutCache = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.cacheSettings = ImageCacheSettings()
        let sessionWithCache = ImageURLSession.createSession()
        
        XCTAssertNil(sessionWithoutCache.configuration.urlCache)
        XCTAssertNotNil(sessionWithCache.configuration.urlCache)
        XCTAssertNotIdentical(sessionWithoutCache, sessionWithCache)
    }
    
    func test_cacheSettings_changeDiskCapacityBytes_withSameSettings_doesNotUpdateURLSession() {
        ImageDownloadSettings.requestSettings.cacheSettings = ImageCacheSettings()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.diskCapacityBytes = .megabyte(5)
        let sessionA = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.diskCapacityBytes = .megabyte(5)
        let sessionB = ImageURLSession.createSession()
        
        XCTAssertIdentical(sessionA, sessionB)
    }
    
    func test_cacheSettings_changeDiskCapacityBytes_withDifferentSettings_updateURLSession() {
        ImageDownloadSettings.requestSettings.cacheSettings = ImageCacheSettings()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.diskCapacityBytes = .megabyte(5)
        let sessionA = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.diskCapacityBytes = .megabyte(25)
        let sessionB = ImageURLSession.createSession()
        
        XCTAssertNotIdentical(sessionA, sessionB)
    }
    
    func test_cacheSettings_changeMemoryCapacityBytes_withSameSettings_doesNotUpdateURLSession() {
        ImageDownloadSettings.requestSettings.cacheSettings = ImageCacheSettings()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.memoryCapacityBytes = .megabyte(5)
        let sessionA = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.memoryCapacityBytes = .megabyte(5)
        let sessionB = ImageURLSession.createSession()
        
        XCTAssertIdentical(sessionA, sessionB)
    }
    
    func test_cacheSettings_changeMemoryCapacityBytes_withDifferentSettings_updateURLSession() {
        ImageDownloadSettings.requestSettings.cacheSettings = ImageCacheSettings()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.memoryCapacityBytes = .megabyte(5)
        let sessionA = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.memoryCapacityBytes = .megabyte(25)
        let sessionB = ImageURLSession.createSession()
        
        XCTAssertNotIdentical(sessionA, sessionB)
    }
    
    func test_cacheSettings_changeDiskPath_withSameSettings_doesNotUpdateURLSession() {
        ImageDownloadSettings.requestSettings.cacheSettings = ImageCacheSettings()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.diskPath = "PATH_1"
        let sessionA = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.diskPath = "PATH_1"
        let sessionB = ImageURLSession.createSession()
        
        XCTAssertIdentical(sessionA, sessionB)
    }
    
    func test_cacheSettings_changeDiskPath_withDifferentSettings_updateURLSession() {
        ImageDownloadSettings.requestSettings.cacheSettings = ImageCacheSettings()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.diskPath = "PATH_1"
        let sessionA = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.diskPath = "PATH_2"
        let sessionB = ImageURLSession.createSession()
        
        XCTAssertNotIdentical(sessionA, sessionB)
    }
    
    func test_cacheSettings_changeRequestCachePolicy_withSameSettings_doesNotUpdateURLSession() {
        ImageDownloadSettings.requestSettings.cacheSettings = ImageCacheSettings()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.requestCachePolicy = .useProtocolCachePolicy
        let sessionA = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.requestCachePolicy = .useProtocolCachePolicy
        let sessionB = ImageURLSession.createSession()
        
        XCTAssertIdentical(sessionA, sessionB)
    }
    
    func test_cacheSettings_changeRequestCachePolicy_withDifferentSettings_updateURLSession() {
        ImageDownloadSettings.requestSettings.cacheSettings = ImageCacheSettings()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.requestCachePolicy = .useProtocolCachePolicy
        let sessionA = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.requestCachePolicy = .reloadIgnoringCacheData
        let sessionB = ImageURLSession.createSession()
        
        XCTAssertNotIdentical(sessionA, sessionB)
    }
    
    func test_cacheSettings_changeCacheExpirationTime_withSameSettings_doesNotUpdateURLSession() {
        ImageDownloadSettings.requestSettings.cacheSettings = ImageCacheSettings()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.cacheExpirationTime = 60
        let sessionA = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.cacheExpirationTime = 60
        let sessionB = ImageURLSession.createSession()
        
        XCTAssertIdentical(sessionA, sessionB)
    }
    
    func test_cacheSettings_changeCacheExpirationTime_withDifferentSettings_updateURLSession() {
        ImageDownloadSettings.requestSettings.cacheSettings = ImageCacheSettings()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.cacheExpirationTime = 60
        let sessionA = ImageURLSession.createSession()
        
        ImageDownloadSettings.requestSettings.cacheSettings?.cacheExpirationTime = 120
        let sessionB = ImageURLSession.createSession()
        
        XCTAssertNotIdentical(sessionA, sessionB)
    }
}
