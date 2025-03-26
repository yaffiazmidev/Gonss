import Foundation
import UIKit


struct versionInfoData: Codable {
    var newVersion: String?
    var minVersion: String?
    var url: String?
    var description: String?
    var forceUpdate: Bool?
    var platform: String?
}


enum updateType : Int {
    case none  = 0
    case option = 1
    case force = 2
}

class UpdateView :UIView{
    var data:versionInfoData?
    var type:updateType.RawValue = 1
    let contentL = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(data:versionInfoData,type:updateType.RawValue) {
        self.init()
        self.data = data
        self.type = type
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor =  UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
    func setupUI(){
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        addSubview(view)
        
        view.anchors.width.equal(288)
        view.anchors.height.greaterThanOrEqual(192)
        view.anchors.center.align()
        
        let titleL = UILabel()
        titleL.text = "Update Available"
        titleL.textColor = .black
        titleL.font = .roboto(.medium, size: 18)
        view.addSubview(titleL)
        titleL.anchors.centerX.align()
        titleL.anchors.top.pin(inset: 24)
        titleL.anchors.height.equal(24)
        
        let contentL = UILabel()
        let text = data?.description ?? ""
         
        contentL.attributedText = text.setLineSpacing(spacing: 6)
        contentL.numberOfLines = 0
        contentL.textAlignment = .center
        contentL.textColor = .boulder
        contentL.font = .roboto(.regular, size: 14)
        view.addSubview(contentL)
        contentL.anchors.edges.pin(insets: 24,axis: .horizontal)
        contentL.anchors.top.equal(titleL.anchors.bottom, constant: 16)
        
        let lineL = UILabel()
        lineL.backgroundColor = .softPeach
        view.addSubview(lineL)
        lineL.anchors.edges.pin(axis: .horizontal)
        lineL.anchors.top.equal(contentL.anchors.bottom, constant: 20)
        lineL.anchors.height.equal(1)
        lineL.anchors.bottom.pin(inset: 55)
        
        let bottomV = UIStackView()
        bottomV.spacing = 3
        bottomV.distribution = .fillEqually
        view.addSubview(bottomV)
        bottomV.anchors.top.equal(lineL.anchors.bottom)
        bottomV.anchors.bottom.pin()
        bottomV.anchors.edges.pin(insets: 6, axis: .horizontal)
         
        if type == updateType.option.rawValue {
            let nextTimeL = getBottomLabel("Next time")
            bottomV.addArrangedSubview(nextTimeL)
            nextTimeL.onTap { [weak self] in
                let timeStamp = Int(Date().timeIntervalSince1970)
                UserDefaults.standard.setValue(timeStamp, forKey: "UpdateVersion")
                self?.removeFromSuperview()
            }
            
            let verticalLineL = UILabel()
            verticalLineL.backgroundColor = .softPeach
            view.addSubview(verticalLineL)
            verticalLineL.anchors.width.equal(1)
            verticalLineL.anchors.top.equal(lineL.anchors.bottom)
            verticalLineL.anchors.bottom.pin()
            verticalLineL.anchors.centerX.align()
        }
        let updateL = getBottomLabel("Update")
        bottomV.addArrangedSubview(updateL)
        updateL.onTap { [weak self] in
            self?.launchAppStore()
        }
    }
    
    
    func getBottomLabel(_ title:String)-> UILabel{
        let label = UILabel()
        label.text = title
        label.textColor = .azure
        label.font = .roboto(.bold, size: 16)
        label.textAlignment = .center
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        return label
    }
    
     
    
    func launchAppStore() {
//        url = URL(string:"https://itunes.apple.com/app/id1539365659")
        guard  let str = data?.url, let url  = URL(string:str) else {  return }
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
      
}
