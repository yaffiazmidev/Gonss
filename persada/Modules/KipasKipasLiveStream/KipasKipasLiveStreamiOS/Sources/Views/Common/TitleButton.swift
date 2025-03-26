//
//  titleButton.swift
//  KipasKipasLiveStreamiOS
//
//  Created by admin on 2024/2/19.
//

import Foundation
import UIKit


public final class TitleButton: UIView {
    public let imageV =  UIImageView()
    public let label = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    
    func configureUI(){
        imageV.contentMode = .scaleAspectFill
        self.addSubview(imageV)
        imageV.anchors.centerX.equal(self.anchors.centerX)
        imageV.anchors.top.equal(anchors.top)
//        imageV.anchors.width.equal(24)
        imageV.anchors.height.equal(imageV.anchors.width)
        
        
        label.font = .roboto(.regular, size: 8)
        label.textColor = .white
        self.addSubview(label)
        label.anchors.centerX.equal(self.anchors.centerX) 
        label.anchors.bottom.equal(self.anchors.bottom)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
}
