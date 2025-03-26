import UIKit
import SwiftUI

// MARK: SwiftUI Preview
public extension UIView {
    // enable preview for UIKit
    // source: https://dev.to/gualtierofr/preview-uikit-views-in-xcode-3543
    @available(iOS 13, *)
    private struct Preview: UIViewRepresentable {
        typealias UIViewType = UIView
        let view: UIView
        func makeUIView(context: Context) -> UIView {
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            //
        }
    }
    
    @available(iOS 13, *)
    func showPreview() -> some View {
        // inject self (the current UIView) for the preview
        Preview(view: self)
    }
	
	func dropShadow(scale: Bool = true) {
		layer.masksToBounds = false
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.1
		layer.shadowOffset = .zero
		layer.shadowRadius = 3

		layer.shouldRasterize = true
		layer.rasterizationScale = scale ? UIScreen.main.scale : 1
	}
}

public func spacer(_ height: CGFloat) -> UIView {
    let view = UIView()
    view.backgroundColor = .clear
    view.anchors.height.equal(height)
    return view
}

public func spacerWidth(_ width: CGFloat) -> UIView {
    let view = UIView()
    view.backgroundColor = .clear
    view.anchors.width.equal(width)
    return view
}

public func invisibleView() -> UIView {
    let view = UIView()
    view.backgroundColor = .clear
    view.setContentHuggingPriority(.defaultLow, for: .horizontal)
    return view
}

extension UIView {
    func loadViewFromNib<T: UIView>() -> T {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: self, options: nil).first as! T
    }
    
    func addSubViews(views: [UIView]){
        views.forEach { view in
            self.addSubview(view)
        }
    }
}

public extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                            left: NSLayoutXAxisAnchor? = nil,
                            bottom: NSLayoutYAxisAnchor? = nil,
                            right: NSLayoutXAxisAnchor? = nil,
                            paddingTop: CGFloat = 0,
                            paddingLeft: CGFloat = 0,
                            paddingBottom: CGFloat = 0,
                            paddingRight: CGFloat = 0,
                            width: CGFloat? = nil,
                            height: CGFloat? = nil) {

        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }

        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }

        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }

        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }

        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func centerInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
        
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func centerXTo(_ anchor: NSLayoutXAxisAnchor) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: anchor).isActive = true
    }
    
    func centerYTo(_ anchor: NSLayoutYAxisAnchor) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: anchor).isActive = true
    }
    
    func centerXToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
    }
    
    func centerYToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
    }

    func getAllScrollViews() -> [UIScrollView] {
        var scrollViews = [UIScrollView]()

        // Check if the current view is a UIScrollView
        if let scrollView = self as? UIScrollView {
            scrollViews.append(scrollView)
        }

        // Recursively traverse the subviews
        for subview in subviews {
            scrollViews += subview.getAllScrollViews()
        }

        return scrollViews
    }

    func setScrollPaging(enable: Bool, except: UIView? = nil) {
        for view in getAllScrollViews() {
            if let x = except {
                if view == x || view.isDescendant(of: x) {
                    continue
                }
            }
            view.isPagingEnabled = enable
            view.isScrollEnabled = enable
        }
    }
}
