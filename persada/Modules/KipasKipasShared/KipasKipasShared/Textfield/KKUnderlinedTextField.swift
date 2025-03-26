import UIKit

/// Represents a line containing path and layer.
final class Line {
    var path = UIBezierPath()
    var layer = CAShapeLayer()
}

/// Custom offset of bottom line.
public struct BorderOffset {
    let x: CGFloat
    let y: CGFloat
}

/// An object of the class can show bottom line permanently.
open class KKUnderlinedTextField: KKBaseTextField {

    enum Settings {
        enum Animation {
            enum Key {
                static let activeStart = "ActiveLineStartAnimation"
                static let activeEnd = "ActiveLineEndAnimation"
            }
        }
    }
    
    /// Specifies offset for the bottom line based on default border coordinates.
    public var borderOffset = BorderOffset(x: .zero, y: .zero)

    public var animationDuration: Double = 1
    
    /// Color of bottom line.
    public var lineColor: UIColor {
        get {
            if let strokeColor = line.layer.strokeColor {
                return UIColor(cgColor: strokeColor)
            }

            return .clear
        } set {
            line.layer.strokeColor = newValue.cgColor
        }
    }

    /// Width of bottom line.
    public var lineWidth: CGFloat {
        get {
            line.layer.lineWidth
        } set {
            line.layer.lineWidth = newValue
        }
    }
    
    /// Color of line that appears when a user begins editing.
    public var activeLineColor: UIColor {
        get {
            if let strokeColor = activeLine.layer.strokeColor {
                return UIColor(cgColor: strokeColor)
            }

            return .clear
        } set {
            activeLine.layer.strokeColor = newValue.cgColor
            tintColor = newValue
        }
    }

    /// Width of line that appears when a user begins editing.
    public var activeLineWidth: CGFloat {
        get {
            activeLine.layer.lineWidth
        } set {
            activeLine.layer.lineWidth = newValue
        }
    }

    private var line = Line()
    private var activeLine = Line()
    
    // MARK: Methods

    /// :nodoc:
    override public init(frame: CGRect) {
        super.init(frame: frame)

        initializeSetup()
    }

    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initializeSetup()
    }

    /// :nodoc:
    override open func layoutSubviews() {
        super.layoutSubviews()

        calculateLine(line)
    }

    private func initializeSetup() {
        observe()
        configureBottomLine()
    }

    private func configureBottomLine() {
        line.layer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(line.layer)
        
        activeLine.layer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(activeLine.layer)
    }
    
    private func observe() {
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(
            self,
            selector: #selector(showLineAnimation),
            name: UITextField.textDidBeginEditingNotification,
            object: self
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(hideLineAnimation),
            name: UITextField.textDidEndEditingNotification,
            object: self
        )
    }

    @objc private func showLineAnimation() {
        calculateLine(activeLine)

        let animation = CABasicAnimation(
            path: #keyPath(CAShapeLayer.strokeEnd),
            fromValue: CGFloat.zero,
            toValue: CGFloat(1),
            duration: animationDuration
        )

        activeLine.layer.add(animation, forKey: Settings.Animation.Key.activeStart)
    }

    @objc private func hideLineAnimation() {
        let animation = CABasicAnimation(
            path: #keyPath(CAShapeLayer.strokeEnd),
            fromValue: nil,
            toValue: CGFloat.zero,
            duration: animationDuration
        )

        activeLine.layer.add(animation, forKey: Settings.Animation.Key.activeEnd)
    }

    private func calculateLine(_ line: Line) {
        // Path
        line.path = UIBezierPath()

        let yOffset = frame.height - (line.layer.lineWidth * 0.5) + borderOffset.y

        let startPoint = CGPoint(x: .zero, y: yOffset)
        line.path.move(to: startPoint)

        let endPoint = CGPoint(x: frame.width + borderOffset.x, y: yOffset)
        line.path.addLine(to: endPoint)

        // Layer
        let interfaceDirection = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute)
        let path = interfaceDirection == .rightToLeft ? line.path.reversing() : line.path

        line.layer.path = path.cgPath
    }
}

private extension CABasicAnimation {

    convenience init(path: String, fromValue: Any?, toValue: Any?, duration: CFTimeInterval) {
        self.init(keyPath: path)

        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration

        isRemovedOnCompletion = false
        fillMode = CAMediaTimingFillMode.forwards
    }
}
