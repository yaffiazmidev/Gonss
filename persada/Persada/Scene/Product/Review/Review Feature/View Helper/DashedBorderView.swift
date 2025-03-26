//
//  DashedBorderView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class DashedBorderView: UIView {
    private let dashedLineColor: CGColor
    private let dashedLinePattern: [NSNumber]
    private let dashedLineWidth: CGFloat
    private let cornerRadius: CGFloat

    private let borderLayer = CAShapeLayer()

    init(dashedLineColor: CGColor = UIColor.black.cgColor, dashedLinePattern: [NSNumber] = [6, 3], dashedLineWidth: CGFloat = 4, cornerRadius: CGFloat = 8.0) {
        self.dashedLineColor = dashedLineColor
        self.dashedLinePattern = dashedLinePattern
        self.dashedLineWidth = dashedLineWidth
        self.cornerRadius = cornerRadius
        super.init(frame: CGRect.zero)

        borderLayer.strokeColor = self.dashedLineColor
        borderLayer.lineDashPattern = self.dashedLinePattern
        borderLayer.backgroundColor = UIColor.clear.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = self.dashedLineWidth
        layer.addSublayer(borderLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
    }
}
