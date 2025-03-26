import Foundation
import Combine
import KipasKipasLiveStream
import KipasKipasNetworking
import KipasKipasShared

protocol LiveRoomCreationAdapterDelegate: AnyObject {
    func creationResult(roomId: String, streamingId: String)
}

final class LiveRoomCreationAdapter {
    
    private let loader: (String, String) -> LiveCreateLoader
    
    private var cancellable: AnyCancellable?
        
    weak var delegate: LiveRoomCreationAdapterDelegate?
    
    init(loader: @escaping (String, String) -> LiveCreateLoader) {
        self.loader = loader
    }
    
    private static var roomId: String {
        let epochInMilliseconds = Date().timeIntervalSince1970 * 1_000
        let roomId = Int(epochInMilliseconds) % 1_000_000_000
        let roomIdStr = String(format: "%#09d", roomId)
        let roomIdWithLeadingZeroRemoved = roomIdStr.replacingOccurrences(of: #"^0"#, with: "\(Int.random(in: 1...9))", options: .regularExpression)
        return roomIdWithLeadingZeroRemoved
    }
    
    func createRoom(roomName: String) {
        let roomId = LiveRoomCreationAdapter.roomId
     
        cancellable = loader(roomId, roomName)
            .dispatchOnMainQueue()
            .sinkReceiveValue { [weak self] result in
                let data = result.data
                self?.delegate?.creationResult(
                    roomId: roomId,
                    streamingId: data.streamingId ?? ""
                )
            }
    }
}
