#if os(OSX)
	import AppKit.NSDataAsset
#elseif os(iOS)
	import UIKit.NSDataAsset
#endif


extension SQLiteWindow {
	func schemaVersioning() throws {
		var version = decode(one: Int.self, from: db, "PRAGMA user_version")!
		if version > 0 && NSDataAsset(name: "v\(version)") == nil {
			throw NSError(domain: "schema", code: version, userInfo: [
				NSLocalizedFailureReasonErrorKey : "Document is of a newer file format ‘\(version)’ that this application version supports",
				])
		}

		version += 1 // run any update scripts beyond the current version number
		sqlite3_exec(db, "BEGIN", nil, nil, nil)

		let fatalErrorWithRollback = { (db: OpaquePointer?, msg: String) -> Never in
			sqlite3_exec(db, "ROLLBACK", nil, nil, nil)
			fatalError(msg)
		}

		for n in version... {
			if let asset = NSDataAsset(name: "v\(n)"), let sql = String(data: asset.data, encoding: .utf8) {
				assert(sql.contains("PRAGMA user_version = \(n);"))

				var msg = UnsafeMutablePointer<Int8>(bitPattern: 0)
				if sqlite3_exec(db, sql, nil, nil, &msg) != SQLITE_OK {
					fatalErrorWithRollback(db, msg != nil ? String(cString: msg!) : "Unknown error")
				}
			} else {
				break
			}
		}

		if let asset = NSDataAsset(name: "v0"), let sql = String(data: asset.data, encoding: .utf8) { // temporary tables/views that need creating every time
			var msg = UnsafeMutablePointer<Int8>(bitPattern: 0)
			if sqlite3_exec(db, sql, nil, nil, &msg) != SQLITE_OK {
				fatalErrorWithRollback(db, msg != nil ? String(cString: msg!) : "Unknown error")
			}
		}

		sqlite3_exec(db, "COMMIT", nil, nil, nil)
	}

}


