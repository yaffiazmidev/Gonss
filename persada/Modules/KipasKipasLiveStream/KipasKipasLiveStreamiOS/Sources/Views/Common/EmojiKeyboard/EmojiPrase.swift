import UIKit

class EmojiPrase: NSObject {

     
    static func findEmojiAttr(emojiText: String, font: UIFont) -> NSMutableAttributedString?{
        
        let pattern = "\\[.*?\\]"
        
        guard let regular = try? NSRegularExpression(pattern: pattern, options: []) else{
            return nil
        }
        let attr = NSMutableAttributedString(string: emojiText)

        let results = regular.matches(in: emojiText, options: [], range: NSRange(location: 0, length: attr.length))
         
        for result in results.reversed(){
            
            let chs = (emojiText as NSString).substring(with: result.range)
             
            if let pngPath = findChsPngPath(chs: chs){
                let attach = NSTextAttachment()
                attach.image = UIImage(contentsOfFile: pngPath)
                attach.bounds =  CGRect(x: 0, y: -4, width: font.lineHeight, height: font.lineHeight)
                attr.replaceCharacters(in: result.range, with: NSAttributedString(attachment: attach))
            }
        }
        return attr
    }
     
    private static func findChsPngPath(chs: String) -> String?{
        let manager = EmojiManager.shared
        for package in manager.emojiPackages {
            for emoji in package.emojis{
                if chs == emoji.chs{
                    return emoji.pngPath
                }
            }
        }
        return nil
    }
}
