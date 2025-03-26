import UIKit

extension CALayer {
    
    public enum BorderSide: String {
        case top = "BORDER_SIDE_TOP"
        case bottom = "BORDER_SIDE_BOTTOM"
        case left = "BORDER_SIDE_LEFT"
        case right = "BORDER_SIDE_RIGHT"
    }
    
    public func addBorder(edge: BorderSide, color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.name = edge.rawValue
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        }
        
        addSublayer(border)
    }
    
    public func addBorders(edges: [BorderSide], color: UIColor, thickness: CGFloat) {
        let uniqueEdges = Set(edges)
        for edge in uniqueEdges {
            addBorder(edge: edge, color: color, thickness: thickness)
        }
    }
    
    public func removeBorders(edges: [BorderSide]) {
        let uniqueEdges = Set(edges)
        for edge in uniqueEdges {
            removeBorder(edge: edge)
        }
    }
    
    public func removeBorder(edge: BorderSide) {
        sublayers?.removeAll { $0.name == edge.rawValue }
    }
}
