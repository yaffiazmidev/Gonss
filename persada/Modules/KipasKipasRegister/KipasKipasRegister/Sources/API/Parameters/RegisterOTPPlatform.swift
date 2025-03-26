import Foundation

public enum RegisterOTPPlatform: String, Encodable {
    case whatsapp = "WHATSAPP"
    case sms = "SMS"
    
    public var desc: String {
        switch self {
        case .sms: "SMS"
        case .whatsapp: "Whatsapp"
        }
    }
}
