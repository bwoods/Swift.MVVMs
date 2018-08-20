import UIKit


extension UIView {

@objc func takeValue(from value: AnyObject) {
	fatalError("takeValue: not overridden for \(self.classForCoder)")
}


}


extension UILabel {

@objc override func takeValue(from value: AnyObject) {
	self.text = (value as! String)
}


}
