import UIKit


fileprivate var networkActivity: Int = 0

extension UIApplication {

static func incrementNetworkActivityCount() {
	DispatchQueue.main.async {
		if networkActivity == 0 {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
		}

		networkActivity += 1;
	}
}

static func decrementNetworkActivityCount() {
	DispatchQueue.main.async {
		networkActivity -= 1;
		if networkActivity == 0 {
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
		}
	}
}

}


