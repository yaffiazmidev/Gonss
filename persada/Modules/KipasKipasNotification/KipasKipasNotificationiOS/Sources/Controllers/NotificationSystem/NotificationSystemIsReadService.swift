import Foundation
import KipasKipasNotification

public class NotificationSystemIsReadService: NotificationSystemCellControllerDelegate {
  
    var service: NotificationSystemService
    
    init(service: NotificationSystemService) {
        self.service = service
    }
    
    public func didSelectIsRead(item: NotificationSystemItem) {
//        service.didRequestSystemIsRead(request: NotificationSystemIsReadRequest(isRead: !item.isRead), types: item.types)
    }
}
