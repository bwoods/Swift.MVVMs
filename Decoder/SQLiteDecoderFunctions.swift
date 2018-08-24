import Foundation


func decode<T: Decodable>(one type: T.Type, from db: OpaquePointer!, _ sql: String) -> T? {
	return try? T(from: SQLiteDecoder(db, sql: sql))
}

func decode<T: Decodable>(all type: T.Type, from db: OpaquePointer!, _ sql: String) -> [T] {
	return (try? [T](from: SQLiteDecoder(db, sql: sql))) ?? [ ]
}


func decode<T: Decodable>(one type: T.Type, from stmt: OpaquePointer!) -> T? {
	return try? T(from: SQLiteDecoder(stmt: stmt))
}

func decode<T: Decodable>(all type: T.Type, from stmt: OpaquePointer!) -> [T] {
	return (try? [T](from: SQLiteDecoder(stmt: stmt))) ?? [ ]
}


