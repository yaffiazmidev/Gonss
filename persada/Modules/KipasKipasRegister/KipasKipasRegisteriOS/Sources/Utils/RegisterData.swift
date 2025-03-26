import Foundation
import KipasKipasRegister

#warning("[BEKA] remove this redundant data model")
public struct RegisterData {
    
    public var otpExpirationDuration = 0
    public var otpType = RegisterOTPPlatform.whatsapp
    public var otpCode = ""
    public var phoneNumber = ""
    public var birthDate = ""
    public var password = ""
    public var username = ""
    public var photoURL = ""
    public var gender = ""
    public var fullName = ""
    public var email = ""
    
    public init(
        otpExpirationDuration: Int = 0,
        otpType: RegisterOTPPlatform = RegisterOTPPlatform.whatsapp,
        otpCode: String = "",
        phoneNumber: String = "",
        birthDate: String = "",
        password: String = "",
        username: String = "",
        photoURL: String = "",
        gender: String = "",
        fullName: String = "",
        email: String = ""
    ) {
        self.otpExpirationDuration = otpExpirationDuration
        self.otpType = otpType
        self.otpCode = otpCode
        self.phoneNumber = phoneNumber
        self.birthDate = birthDate
        self.password = password
        self.username = username
        self.photoURL = photoURL
        self.gender = gender
        self.fullName = fullName
        self.email = email
    }
    
    /*
    func log() {
        var asDictionary : [String:Any] {
           let mirror = Mirror(reflecting: self)
           let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
             guard let label = label else { return nil }
             return (label, value)
           }).compactMap { $0 })
           return dict
         }
        
        print("[BEKA] register data", asDictionary as AnyObject)
    }
     */
}
