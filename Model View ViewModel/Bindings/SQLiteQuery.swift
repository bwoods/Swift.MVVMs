import Foundation


class SQLiteQuery: NSObject {
	var array: [[String : NSObject]] = [ ]

	var keys: [String] = [ ]
	var db: OpaquePointer! { return sqlite3_db_handle(stmt) }
	var stmt = OpaquePointer(bitPattern: 0) {
		didSet {
			var tables: Set<String> = [ ]
			for column in 0..<sqlite3_column_count(stmt) {
				keys.append(String(cString: sqlite3_column_name(stmt, column)))
				tables.insert(String(cString: sqlite3_column_table_name(stmt, column)))
			}

			self.updateHook = { [weak self, tables] (type: Int32, table: String, rowid: Int64) in
				if tables.contains(table) {
					self?.reloadData()
				}
			}
		}
	}

	@IBOutlet var owner: NSObject? {
		willSet { assert(newValue == nil || newValue!.responds(to: Selector(("window")))) }
		didSet { reloadData() }
	}

	@IBInspectable
	var query: String! { didSet { reloadData() } }

//	@IBInspectable
//	var insertionSurrogateKey: String?
	@IBAction func insert(_ sender: AnyObject) {
//		assert(insertionSurrogateKey != nil && insertionSurrogateKey!.count > 0)

		self.query.withCString { query in
//			self.insertionSurrogateKey!.withCString { column in
				let sql = withVaList([ query ]) { args in return sqlite3_vmprintf("INSERT INTO %s DEFAULT VALUES", args) }; defer { sqlite3_free(sql) }
				print(String(cString: sql!))
				if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK {
					fatalError(String(cString: sqlite3_errmsg(db)))
				}
//			}
		}
	}

// MARK: -
	func reloadData() {
		guard query != nil && owner != nil else {
			return
		}

		guard stmt != OpaquePointer(bitPattern: 0) else {
			DispatchQueue.main.async { // awakeFromNib sets key-values before the view is in the window
				let selector = Selector(("window")) // double parens remove the compiler warning about an arbitrary method selector
				let window = self.owner!.perform(selector)?.takeUnretainedValue() as? SQLiteWindow

				guard window != nil else {
					DispatchQueue.main.async {
						self.reloadData() // owner is not actually in a window yet; try next cycle…
					}
					return
				}

				let db = window!.db
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

		defer { sqlite3_reset(stmt) }
		var array: [[String : NSObject]] = [ ]

		while sqlite3_step(stmt) == SQLITE_ROW {
			var result = [String : NSObject](minimumCapacity: numericCast(sqlite3_column_count(stmt)))

			for column in (0..<sqlite3_column_count(stmt)) {
				let type = sqlite3_column_type(stmt, column)
				guard type != SQLITE_NULL else {
					continue // skip NULL values
				}

				result[String(cString: sqlite3_column_name(stmt, column))] = {
					switch type {
					case SQLITE_INTEGER: return NSNumber(value: sqlite3_column_int64(stmt, column))
					case SQLITE_FLOAT: return NSNumber(value: sqlite3_column_double(stmt, column))
					case SQLITE_TEXT: return NSString(bytes: sqlite3_column_text(stmt, column), length: numericCast(sqlite3_column_bytes(stmt, column)), encoding: String.Encoding.utf8.rawValue)
					case SQLITE_BLOB: return NSData(bytes: sqlite3_column_blob(stmt, column), length: numericCast(sqlite3_column_bytes(stmt, column)))
					default: fatalError()
					}
				}()
			}

			array.append(result)
		}

		self.array = array
	}

// MARK: - Array methods
	var count: Int {
		return array.count
	}

	subscript(index: Int) -> [String : NSObject] {
		return array[index]
	}

	deinit {
		sqlite3_finalize(stmt)
	}

}


