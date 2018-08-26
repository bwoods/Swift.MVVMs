import UIKit


@IBDesignable
class TintedLabel: UILabel {
	override func willMove(toWindow window: UIWindow?) {
		super.willMove(toWindow: window)

		self.textColor = window?.tintColor
	}

}
