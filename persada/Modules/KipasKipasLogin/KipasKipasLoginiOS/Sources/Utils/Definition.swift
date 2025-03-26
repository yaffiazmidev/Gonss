import UIKit

public typealias Phone = String

internal let platform: String = "WHATSAPP"
internal let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
