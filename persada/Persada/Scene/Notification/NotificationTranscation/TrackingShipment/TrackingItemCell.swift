//
//  TrackingItemCell.swift
//  KipasKipas
//
//  Created by movan on 19/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class TrackingItemCell: UITableViewCell {

    @IBOutlet weak var lineUpView: UIView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.backgroundColor = .white
		

		
	}
	
	required init?(coder: NSCoder) {
        super.init(coder: coder)
	}
	
    func configure(_ date: Int, _ subtitle: String, _ color: UIColor, _ hideLastLine : Bool, _ hideFirstLine : Bool) {
		circleView.backgroundColor = color
        
        
        		
        let dateFromMillis = Date(timeIntervalSince1970: TimeInterval(date) / 1000)
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy HH:mm"
        
        
		self.titleLabel.text = df.string(from: dateFromMillis)
        self.descLabel.text = subtitle
        if color == UIColor.secondary {
            descLabel.font = .Roboto(.bold, size: 12)
            descLabel.textColor = color
        }
        
        if hideLastLine {
            lineView.isHidden = true
        }
        
        if hideFirstLine {
            lineUpView.isHidden = true
        }
	}
}
