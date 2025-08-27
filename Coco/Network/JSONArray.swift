//
//  JSONArray.swift
//  Coco
//
//  Created by Jackie Leonardy on 01/07/25.
//

import Foundation

protocol JSONArrayProtocol {
    init(jsonArray: [JSONObject]) throws
}

extension JSONArray: JSONArrayProtocol {}

struct JSONArray<T: JSONDecodable>: JSONDecodable {
    let values: [T]

    init(json: JSONObject) throws {
        throw NSError(domain: "JSONArray init expects a top-level array, not an object", code: -1)
    }

    init(jsonArray: [JSONObject]) throws {
        self.values = try jsonArray.map { try T(json: $0) }
    }
}

extension Array: JSONDecodable where Element: JSONDecodable {
    init(json: JSONObject) throws {
        // Arrays should be decoded from JSON arrays, not objects
        throw NSError(domain: "Array init expects a top-level array in jsonArray parameter", code: -1)
    }
}

extension Array: JSONArrayProtocol where Element: JSONDecodable {
    init(jsonArray: [JSONObject]) throws {
        self = try jsonArray.map { try Element(json: $0) }
    }
}
