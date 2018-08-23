import Foundation


func decode<T: Decodable>(from db: OpaquePointer!, one type: T.Type, _ sql: String) -> T? {
	var stmt = OpaquePointer(bitPattern: 0)
	if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
		fatalError(String(cString: sqlite3_errmsg(db)))
	}
	defer { sqlite3_finalize(stmt) }
	return try? SQLiteDecoder(stmt!).singleValueContainer().decode(T.self)
}


