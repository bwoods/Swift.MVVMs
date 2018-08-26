import UIKit


import UIKit

@IBDesignable
class DecorativeFrameView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { layer.borderWidth = borderWidth }
    }

    @IBInspectable var borderColor: UIColor? {
        didSet { layer.borderColor = borderColor?.cgColor }
    }

    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        didSet { layer.shadowOffset = shadowOffset }
    }

    @IBInspectable var shadowColor: UIColor? {
        didSet { layer.shadowColor = shadowColor?.cgColor }
    }

    @IBInspectable var shadowAlpha: Float = 0 {
        didSet { layer.shadowOpacity = shadowAlpha }
    }

    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet { layer.shadowRadius = shadowRadius }
    }

}


