import UIKit

@objcMembers
class EmojiModel: NSObject {

    var chs: String?
    var png: String?{
        didSet{
            if let png = png {
                if let path = Bundle.main.path(forResource: "EmojiKeyBoard.bundle", ofType: nil){
                    pngPath = path + "/" + png
                }
                
            }
        }
    }
    var code: String?{
        didSet{
            if let code = code{
                let scanner = Scanner(string: code)
                var result: UInt32 = 0
                scanner.scanHexInt32(&result)
                let c = Character(UnicodeScalar(result)!)
                emojiCode = String(c)
            }
        }
    }
     
    var emojiCode: String?
     
    var pngPath: String?
     
    var isDelete: Bool = false
     
    var isSpace: Bool = false
    
     init(dict: [String: String]) {
        super.init()
        
        setValuesForKeys(dict)

    }
    
    init(isDelete: Bool) {
        super.init()
        self.isDelete = true
    }
    
    init(isSpace: Bool) {
        super.init()
        self.isSpace = true
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
