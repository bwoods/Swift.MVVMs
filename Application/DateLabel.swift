import UIKit


@IBDesignable
class DateLabel: UILabel {
	@objc func updateDateString(_ notification: Notification?) {
		self.text = DateLabel.dateFormatter.string(from: Date()).uppercased()
		self.sizeToFit()
	}

	static var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.doesRelativeDateFormatting = false
		formatter.dateStyle = .full
		formatter.timeStyle = .none

		return formatter
		}()

	override func awakeFromNib() {
		super.awakeFromNib()

		// “If your app targets iOS 9.0 and later or macOS 10.11 and later, you don't need to unregister an observer in its dealloc method.”
		NotificationCenter.default.addObserver(self, selector: #selector(updateDateString), name: NSNotification.Name.UIApplicationSignificantTimeChange, object: nil)
		updateDateString(nil)
	}

}
