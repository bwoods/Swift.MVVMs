#if os(OSX)
	import AppKit.NSDataAsset
#elseif os(iOS)
	import UIKit.NSDataAsset
#endif


extension SQLiteWindow {
	func schemaVersioning() throws {
		var stmt = OpaquePointer(bitPattern: 0)
		if sqlite3_prepare_v2(db, "PRAGMA user_version", -1, &stmt, nil) != SQLITE_OK { fatalError(String(cString: sqlite3_errmsg(db))); }
		defer { sqlite3_finalize(stmt) }

		if sqlite3_step(stmt) == SQLITE_ROW {
			var version: Int = numericCast(sqlite3_column_int(stmt, 0))
			if version > 0 && NSDataAsset(name: "v\(version)") == nil {
				throw NSError(domain: "schema", code: version, userInfo: [
					NSLocalizedFailureReasonErrorKey : "Document is of a newer file format \(version) that this application version supports",
					])
			}

			version += 1 // run any update scripts beyond the current version number
			sqlite3_exec(db, "BEGIN", nil, nil, nil)
			for n in version... {
				if let asset = NSDataAsset(name: "v\(n)") {
					if sqlite3_exec(db, String(data: asset.data, encoding: .utf8)!, nil, nil, nil) != SQLITE_OK { fatalError(String(cString: sqlite3_errmsg(db))) }
				} else {
					break
				}
			}

			if let asset = NSDataAsset(name: "v0") { // temporary tables/views that need creating every time
				if sqlite3_exec(db, String(data: asset.data, encoding: .utf8)!, nil, nil, nil) != SQLITE_OK {
					fatalError(String(cString: sqlite3_errmsg(db)))
				}
			}

			sqlite3_exec(db, "COMMIT", nil, nil, nil)
		}
	}

}


