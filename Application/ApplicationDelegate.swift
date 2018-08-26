import UIKit


@UIApplicationMain
class ApplicationDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

// MARK: - Application State Resoration
	func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
		return true
	}

	func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
		return true
	}

// MARK: - Application Launching
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// we should be calling `self.window!.makeKeyAndVisible()`(see https://stackoverflow.com/a/42862265) but that causes viewWIllAppear to be called before the UIStateRestoring methods have been called
		self.window!.tintColor = UIColor(named: "ApplicationTintColor")
		return true
	}

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


