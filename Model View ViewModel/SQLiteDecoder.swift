import Foundation


/// Decodes a single row
class SQLiteDecoder: Decoder, UnkeyedDecodingContainer, SingleValueDecodingContainer {
	let stmt: OpaquePointer
	public init(_ stmt: OpaquePointer) {
		self.stmt = stmt
		self.count = numericCast(sqlite3_column_count(stmt))
		try! step() // didSet is not run within an init()
	}

	func step() throws {
		switch sqlite3_step(stmt) {
			case SQLITE_ROW: fallthrough
			case SQLITE_DONE: break
			default: throw NSError(domain: "sqlite", code: numericCast(sqlite3_errcode(sqlite3_db_handle(stmt))), userInfo: [
				NSLocalizedFailureReasonErrorKey : String(cString: sqlite3_errmsg(sqlite3_db_handle(stmt))),
				])
		}
	}

	fileprivate static var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "%Y%m%d%H%M%f"
		return formatter
		}()

// MARK: - Decoder methods
    var codingPath: [CodingKey] { return [ ] }
    var userInfo: [CodingUserInfoKey : Any] { return [ : ] }

	func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey { return KeyedDecodingContainer(KeyedContainer<Key>(decoder: self)) }
	func unkeyedContainer() throws -> UnkeyedDecodingContainer { return self }
	func singleValueContainer() throws -> SingleValueDecodingContainer { return self }

// MARK: - KeyedDecodingContainerProtocol struct
    private struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        var decoder: SQLiteDecoder
		init(decoder: SQLiteDecoder) {
    		self.decoder = decoder
    		allKeys = (0..<decoder.count!).map { Key(stringValue: String(cString: sqlite3_column_name(decoder.stmt, numericCast($0))))! }
		}

        var allKeys: [Key]
        var codingPath: [CodingKey] { return [ ] }
		func contains(_ key: Key) -> Bool { return allKeys.contains { $0.stringValue == key.stringValue } }

		func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
			decoder.currentIndex = numericCast(sqlite3_bind_parameter_index(decoder.stmt, key.stringValue))
			return try decoder.decode(T.self)
        }

        func decodeNil(forKey key: Key) throws -> Bool { return decoder.decodeNil() }
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey { return try decoder.container(keyedBy: type) }
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer { return try decoder.unkeyedContainer() }
        func superDecoder() throws -> Decoder { return decoder }
        func superDecoder(forKey key: Key) throws -> Decoder { return decoder }
    }

// MARK: - UnkeyedDecodingContainer methods
	var count: Int? // our is always set
	var isAtEnd: Bool { return currentIndex == count }
	var currentIndex: Int = 0 { didSet { try! step() } }

	func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey { return try container(keyedBy: type) }
	func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer { return self }
	func superDecoder() throws -> Decoder { return self }

// MARK: - SingleValueDecodingContainer methods
	func decode<T: Decodable>(_ type: T.Type) throws -> T {
		defer { currentIndex += 1 }

		switch type {
		case is Int.Type: return Int(truncatingIfNeeded: sqlite3_column_int64(stmt, numericCast(currentIndex))) as! T
		case is UInt.Type: return UInt(truncatingIfNeeded: sqlite3_column_int64(stmt, numericCast(currentIndex))) as! T
		case is Bool.Type: return Bool(sqlite3_column_int(stmt, numericCast(currentIndex)) != 0) as! T
		case is Float.Type: return Float(sqlite3_column_double(stmt, numericCast(currentIndex))) as! T
		case is Double.Type: return sqlite3_column_double(stmt, numericCast(currentIndex)) as! T
		case is String.Type: return String(cString: sqlite3_column_text(stmt, numericCast(currentIndex))) as! T
		case is Date.Type: return SQLiteDecoder.dateFormatter.date(from: String(cString: sqlite3_column_text(stmt, numericCast(currentIndex)))) as! T
		case is Data.Type: return Data(bytes: sqlite3_column_blob(stmt, numericCast(currentIndex)), count: numericCast(sqlite3_column_bytes(stmt, numericCast(currentIndex)))) as! T
		default: fatalError()
        }
	}

	func decodeNil() -> Bool {
		guard sqlite3_column_type(stmt, numericCast(currentIndex)) == SQLITE_NULL else {
			return false
		}

		currentIndex += 1
		return true
	}

}


