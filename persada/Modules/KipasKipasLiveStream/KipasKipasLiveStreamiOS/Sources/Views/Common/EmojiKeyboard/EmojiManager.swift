import UIKit


class EmojiManager: NSObject {

    static let shared: EmojiManager = EmojiManager()
    
    var emojiPackages = [EmojiPackage]()
    
    var deletePath: String?
      
    override init() {
        super.init()
        let tempDict = ["name":"默认表情","id":"com.apple.emoji"]
         
        emojiPackages.append(EmojiPackage(dict: tempDict))
        
//        emojiPackages.append(EmojiPackage(dict: array[0]))
        
//        for dict  in array {
//           emojiPackages.append(EmojiPackage(dict: dict))
//        }
        
        //deletePath
        guard let deletePath = Bundle.main.path(forResource: "delete@3x.png", ofType: nil, inDirectory: "EmojiKeyBoard.bundle") else{
            return
        }
        self.deletePath = deletePath
    }
}
