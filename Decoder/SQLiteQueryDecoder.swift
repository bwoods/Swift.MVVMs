import Foundation


struct SQLiteQueryDecoder: UnkeyedDecodingContainer {
	let stmt: OpaquePointer
	var status: Int32

	init(stmt: OpaquePointer) {
		self.stmt = stmt
		self.status = sqlite3_errcode(sqlite3_db_handle(stmt))
	}

	func decoder(for column: Int32) -> SQLiteValueDecoder {
		return SQLiteValueDecoder(stmt: stmt, column: column)
	}

// MARK: - UnkeyedDecodingContainer methods
	var codingPath: [CodingKey] = [ ]
	var count: Int? = nil // we never know until the query returns SQLITE_DONE
	var isAtEnd: Bool { return status != SQLITE_ROW }
	var currentIndex: Int = 0

	func decodeNil() throws -> Bool { return decoder(for: 0).decodeNil() }
	mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
		defer { status = sqlite3_step(stmt) }
		return try decoder(for: 0).decode(T.self)
	}

	func superDecoder() throws -> Decoder { return SQLiteDecoder(stmt: stmt) }
	func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer { return self }
	func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
		return try SQLiteDecoder(stmt: stmt).container(keyedBy: type)
	}

}

