import Foundation


class SQLiteDecoder: Decoder {
	private let stmt: OpaquePointer
	init(stmt: OpaquePointer) {
		self.stmt = stmt
	}

	deinit {
		if finalize {
			sqlite3_finalize(stmt)
		}
	}

	private var finalize = false
	convenience init(_ db: OpaquePointer, sql: String) throws {
		var stmt = OpaquePointer(bitPattern: 0)
		if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
			fatalError(String(cString: sqlite3_errmsg(db)))
		}

		self.init(stmt: stmt!)
		finalize = true

		if (SQLITE_ROW...SQLITE_DONE).contains(sqlite3_step(stmt)) == false {
			throw NSError(domain: "sqlite", code: numericCast(sqlite3_errcode(sqlite3_db_handle(stmt))), userInfo: [
				NSLocalizedFailureReasonErrorKey : String(cString: sqlite3_errmsg(sqlite3_db_handle(stmt))),
				])
		}
	}

// MARK: - Decoder methods
	var codingPath: [CodingKey] = [ ]
	var userInfo: [CodingUserInfoKey : Any] = [ : ]

	func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
		return KeyedDecodingContainer(SQLiteRowDecoder<Key>(stmt: stmt))
	}

	func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		return SQLiteQueryDecoder(stmt: stmt)
	}

	func singleValueContainer() throws -> SingleValueDecodingContainer {
		return SQLiteValueDecoder(stmt: stmt, column: 0)
	}

}


