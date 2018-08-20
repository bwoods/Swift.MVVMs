import Foundation


@IBDesignable
class SQLiteQuery: NSObject {
	var array: [[String : AnyObject]] = [ ]

	var keys: [String] = [ ]
	var stmt = OpaquePointer(bitPattern: 0) {
		didSet {
			for column in 0..<sqlite3_column_count(stmt) {
				keys.append(String(cString: sqlite3_column_name(stmt, column)))

				var tables: Set<String> = [ ]
				let name = String(cString: sqlite3_column_table_name(stmt, column))
				tables.insert(name)

				self.updateHook = { [weak self] (type: Int32, table: String, rowid: Int64) in
					if tables.contains(table) { // tables captured by value
						self?.reloadData()
					}
				}
			}
		}
	}

	@IBOutlet var owner: NSObject! {
		willSet { assert(newValue.responds(to: Selector(("window")))) }
		didSet { reloadData() }
	}

	@IBInspectable
	var query: String! { didSet { reloadData() } }

// MARK: -
	func reloadData() {
		guard query != nil && owner != nil else {
			return
		}

		guard stmt != OpaquePointer(bitPattern: 0) else {
			DispatchQueue.main.async { // awakeFromNib sets key-values before the view is in the window
				let selector = Selector(("window")) // double parens remove the compiler warning about an arbitrary method selector
				let window = self.owner.perform(selector).takeUnretainedValue() as! SQLiteWindow
				let db = window.db

				var stmt = OpaquePointer(bitPattern: 0)
				self.query.withCString { cString in
					let sql = withVaList([ cString ]) { args in return sqlite3_vmprintf("SELECT * FROM (%s)", args) }; defer { sqlite3_free(sql) }
					if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
						fatalError(String(cString: sqlite3_errmsg(db)))
					}
				}

				self.stmt = stmt
				self.reloadData() // now try again…
			}

			return
		}

		var array: [[String : AnyObject]] = [ ]
		while sqlite3_step(stmt) == SQLITE_ROW {
			var result: [String : AnyObject] = [:]

			for column in (0..<sqlite3_column_count(stmt)) {
				if sqlite3_column_type(stmt, column) != SQLITE_NULL {
					result[String(cString: sqlite3_column_name(stmt, column))] = {
						switch sqlite3_column_type(stmt, column) {
						case SQLITE_INTEGER: return NSNumber(value: sqlite3_column_int64(stmt, column))
						case SQLITE_FLOAT: return NSNumber(value: sqlite3_column_double(stmt, column))
						case SQLITE_TEXT: return NSString(bytes: sqlite3_column_text(stmt, column), length: numericCast(sqlite3_column_bytes(stmt, column)), encoding: String.Encoding.utf8.rawValue)
						case SQLITE_BLOB: return NSData(bytes: sqlite3_column_blob(stmt, column), length: numericCast(sqlite3_column_bytes(stmt, column)))
						default: fatalError()
						}
					}()
				}
			}

			array.append(result)
		}

		sqlite3_reset(stmt)
		self.array = array
	}

// MARK: - Array methods
	var count: Int {
		return array.count
	}

	subscript(index: Int) -> [String : AnyObject] {
		return array[index]
	}

	deinit {
		sqlite3_finalize(stmt)
	}

}

