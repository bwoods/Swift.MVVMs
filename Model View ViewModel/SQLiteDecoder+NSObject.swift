import Foundation


extension SQLiteDecoder {

	func decode(_ type: NSObject.Type) throws -> NSObject? {
		defer { currentIndex += 1 }
		let column: Int32 = numericCast(currentIndex)

		switch sqlite3_column_type(stmt, column) {
		case SQLITE_INTEGER: return NSNumber(value: sqlite3_column_int64(stmt, column))
		case SQLITE_FLOAT: return NSNumber(value: sqlite3_column_double(stmt, column))
		case SQLITE_TEXT: return NSString(bytes: sqlite3_column_text(stmt, column), length: numericCast(sqlite3_column_bytes(stmt, column)), encoding: String.Encoding.utf8.rawValue)
		case SQLITE_BLOB: return NSData(bytes: sqlite3_column_blob(stmt, column), length: numericCast(sqlite3_column_bytes(stmt, column)))
		case SQLITE_NULL: return nil
		default: fatalError()
		}
	}

}


