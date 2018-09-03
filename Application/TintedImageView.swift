import UIKit


class TintedImageView: UIImageView {

	override func awakeFromNib() {
		super.awakeFromNib()

		self.tintColorDidChange() // http://openradar.appspot.com/23759908
	}
}
