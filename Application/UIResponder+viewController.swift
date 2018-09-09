import UIKit


extension UIResponder {
	var viewController: UIViewController? {
		return self as? UIViewController ?? next?.viewController
	}

}


