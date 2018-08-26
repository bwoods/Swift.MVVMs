#if os(OSX)
	import AppKit
	typealias Window = NSWindow
#elseif os(iOS)
	import UIKit
	typealias Window = UIWindow
#endif


/// These constants are not properly exposed to Swift
let SQLITE_STATIC = unsafeBitCast(OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)


/**

*/
class SQLiteWindow : Window {
	var db: OpaquePointer! = OpaquePointer(bitPattern: 0) {
		didSet {
			sqlite3_exec(db, "PRAGMA foreign_keys = TRUE", nil, nil, nil)
			sqlite3_update_hook(db, { (pointer, type, database, table, rowid) in
				DispatchQueue.main.async { // delay the callback until after the database hook in case the callback wants to write to the database
					for object in unsafeBitCast(pointer, to: NSMapTable<AnyObject, SQLiteUpdateHook>.self).objectEnumerator()! {
						let hook = object as! SQLiteUpdateHook
						hook.callback(type, String(bytesNoCopy: UnsafeMutableRawPointer(mutating: table!), length: strlen(table!), encoding: .utf8, freeWhenDone: false)!, rowid)
					}
				}
			}, unsafeBitCast(callbacks, to: UnsafeMutableRawPointer.self))

			try! schemaVersioning()
		}
	}

	fileprivate class SQLiteUpdateHook {
		init(_ callback: @escaping (Int32, String, Int64) -> Void) { self.callback = callback }
		let callback: ((Int32, String, Int64) -> Void)
	}
	fileprivate var callbacks = NSMapTable<AnyObject, SQLiteUpdateHook>(keyOptions: NSMapTableWeakMemory, valueOptions: NSMapTableStrongMemory)


	var filename: String! {
		willSet { assert(newValue.lengthOfBytes(using: .utf8) > 0) }
		didSet {
			var url = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
			url.appendPathComponent(filename)

			var db = OpaquePointer(bitPattern: 0)
			if sqlite3_open_v2(url.path, &db, SQLITE_OPEN_READWRITE+SQLITE_OPEN_CREATE, nil) != SQLITE_OK {
				fatalError(String(cString: sqlite3_errmsg(db)))
			}

			sqlite3_close_v2(self.db)
			self.db = db!
		}
	}
}


/**

*/
fileprivate class SQLiteUpdateHook {
	init(_ callback: @escaping (Int32, String, Int64) -> Void) { self.callback = callback }
	let callback: ((Int32, String, Int64) -> Void)
}

fileprivate var callbacks = NSMapTable<NSObject, SQLiteUpdateHook>(keyOptions: NSMapTableWeakMemory, valueOptions: NSMapTableStrongMemory)

extension NSObject {
	var updateHook: ((Int32, String, Int64) -> Void)? { // (type: Int32, table: String, rowid: Int64) in
		get { return callbacks.object(forKey: self)?.callback }
		set {
			if let hook = newValue {
				callbacks.setObject(SQLiteUpdateHook(hook), forKey: self)
			} else {
				callbacks.removeObject(forKey: self)
			}
		}
	}
}



