import UIKit


extension SQLiteQuery {
	func fill(_ view: UIView, with value: [String : NSObject]) {
		keys.enumerated().forEach { (index, key) in
			let tag = index+1
			view.viewWithTag(tag)?.takeValue(from: value[key]!)
		}
	}
}

// MARK: -
extension UIView {

@objc func takeValue(from value: NSObject) {
	fatalError("takeValue: not overridden for \(self.classForCoder)")
}


}


extension UILabel {

@objc override func takeValue(from value: NSObject) {
	self.text = (value as! String)
}


}
