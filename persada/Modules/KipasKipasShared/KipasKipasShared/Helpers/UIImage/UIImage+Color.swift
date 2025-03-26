import UIKit

extension UIImage {
    public func averageColor(rect: CGRect) -> UIColor? {
        guard let inputImage = CIImage(image: self)?.cropped(to: rect) else { return nil }
        let extentVector = CIVector(x: rect.origin.x, y: rect.origin.y, z: rect.size.width, w: rect.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
    }
    
    public func averageColors() -> (top: UIColor?, bottom: UIColor?) {
        let halfHeight = size.height / 2
        let topRect = CGRect(x: 0, y: 0, width: size.width, height: halfHeight)
        let bottomRect = CGRect(x: 0, y: halfHeight, width: size.width, height: halfHeight)
        
        let topColor = averageColor(rect: topRect)
        let bottomColor = averageColor(rect: bottomRect)
        
        return (topColor, bottomColor)
    }
}


