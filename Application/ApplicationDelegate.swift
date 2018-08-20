import UIKit


@UIApplicationMain
class ApplicationDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		return true
	}


// MARK: -
	override init() {
		super.init()
		
		let window = SQLiteWindow(frame: UIScreen.main.bounds)
		window.filename = "versioning.db"

		self.window = window
	}

}


