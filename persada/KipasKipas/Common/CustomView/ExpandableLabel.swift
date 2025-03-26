import UIKit
import KipasKipasShared

class ExpandableLabel: UILabel {
    
    var isExpaded = false
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.image = UIImage(systemName: "arrow.down")
        img.tintColor = .ashGrey
        return img
    } ()
  
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        UIFont.loadCustomFonts
        let buttonAray =  self.superview?.subviews.filter({ (subViewObj) -> Bool in
            return subViewObj.tag ==  9090
        })
        
        if buttonAray?.isEmpty == true {
            self.addReadMoreButton()
        }
    }
    
    //Add readmore button in the label.
    func addReadMoreButton() {
        
        let theNumberOfLines = numberOfLinesInLabel(yourString: self.text ?? "", labelWidth: self.frame.width, labelHeight: self.frame.height, font: self.font)
        let height = self.frame.height
        self.numberOfLines =  self.isExpaded ? 0 : 4
        
        if theNumberOfLines > 4 {
            
            self.numberOfLines = 4
            
            let button = UIButton(frame: CGRect(x: 0, y: height+15, width: 70, height: 15))
            button.tag = 9090
            button.frame = self.frame
            button.frame.origin.y =  self.frame.origin.y  +  self.frame.size.height + 25
            button.setTitle("Lihat lebih banyak", for: .normal)
            button.titleLabel?.font = .roboto(.regular, size: 12)
            button.backgroundColor = .clear
            button.setTitleColor(UIColor.ashGrey, for: .normal)
            button.addTarget(self, action: #selector(ExpandableLabel.buttonTapped(sender:)), for: .touchUpInside)
            self.superview?.addSubview(button)
            self.superview?.addSubview(imgView)
            self.superview?.bringSubviewToFront(button)
            button.setTitle("Sembunyikan", for: .selected)
            button.isSelected = self.isExpaded
            button.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                button.bottomAnchor.constraint(equalTo:  self.bottomAnchor, constant: +35)
            ])
            
            imgView.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: +6).isActive = true
            imgView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -5).isActive = true
            imgView.widthAnchor.constraint(equalToConstant: 12).isActive = true
            imgView.heightAnchor.constraint(equalToConstant: 15).isActive = true
            
        }else{
            self.numberOfLines = 4
        }
    }
    
    //Calculating the number of lines. -> Int
    func numberOfLinesInLabel(yourString: String, labelWidth: CGFloat, labelHeight: CGFloat, font: UIFont) -> Int {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = labelHeight
        paragraphStyle.maximumLineHeight = labelHeight
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): font, NSAttributedString.Key(rawValue: NSAttributedString.Key.paragraphStyle.rawValue): paragraphStyle]
        
        let constrain = CGSize(width: labelWidth, height: CGFloat(Float.infinity))
        
        let size = yourString.size(withAttributes: attributes)
        
        let stringWidth = size.width
        
        let numberOfLines = ceil(Double(stringWidth/constrain.width))
        
        return Int(numberOfLines)
    }
    
    //ReadMore Button Action
    @objc func buttonTapped(sender : UIButton) {
        
        self.isExpaded = !isExpaded
        sender.isSelected =   self.isExpaded
        
        self.numberOfLines =  sender.isSelected ? 0 : 4
        if self.isExpaded {
            imgView.image = UIImage(systemName: "arrow.up")?.withTintColor(.ashGrey)
        } else {
            imgView.image = UIImage(systemName: "arrow.down")?.withTintColor(.ashGrey)
        }
        self.layoutIfNeeded()
        
        var viewObj: UIView?  = self
        var cellObj: UITableViewCell?
        while viewObj?.superview != nil  {
            if let cell = viewObj as? UITableViewCell  {
                cellObj = cell
            }
            if let tableView = (viewObj as? UITableView)  {
                if let indexPath = tableView.indexPath(for: cellObj ?? UITableViewCell()){
                    tableView.beginUpdates()
                    print(indexPath)
                    tableView.endUpdates()
                }
                return
            }
            viewObj = viewObj?.superview
        }
        
        
    }
    
}

