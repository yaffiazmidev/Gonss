import UIKit

public var dimension: Dimension {
    UIDevice.current.orientation.isPortrait ? .width : .height
}

public func resized(size: CGSize, basedOn dimension: Dimension) -> CGSize {
    let screenSize = UIScreen.current?.bounds.size ?? UIScreen.main.bounds.size
    
    let screenWidth  = screenSize.width
    let screenHeight = screenSize.height
    
    var ratio:  CGFloat = 0.0
    var width:  CGFloat = 0.0
    var height: CGFloat = 0.0
    
    switch dimension {
    case .width:
        ratio  = size.height / size.width
        width  = screenWidth * (size.width / Device.baseScreenSize.rawValue.width)
        height = width * ratio
    case .height:
        ratio  = size.width / size.height
        height = screenHeight * (size.height / Device.baseScreenSize.rawValue.height)
        width  = height * ratio
    }
    
    return CGSize(width: width, height: height)
}

public func adapted(dimensionSize: CGFloat, to dimension: Dimension) -> CGFloat {
    let screenSize = UIScreen.current?.bounds.size ?? UIScreen.main.bounds.size
    
    let screenWidth  = screenSize.width
    let screenHeight = screenSize.height
    
    var ratio: CGFloat = 0.0
    var resultDimensionSize: CGFloat = 0.0
    
    switch dimension {
    case .width:
        ratio = dimensionSize / Device.baseScreenSize.rawValue.width
        resultDimensionSize = screenWidth * ratio
    case .height:
        ratio = dimensionSize / Device.baseScreenSize.rawValue.height
        resultDimensionSize = screenHeight * ratio
    }
    
    return resultDimensionSize
}

