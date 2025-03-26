// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let postalCode = try? newJSONDecoder().decode(PostalCode.self, from: jsonData)

import Foundation

// MARK: - PostalCode
struct NewPostalCodeResult: Codable {
    let message: String
    let data: DataClass
    let code: String
}

// MARK: - DataClass
struct DataClass: Codable {
    let postalCodes: [PostalCodeElement]
    let subDistrict: String
}

// MARK: - PostalCodeElement
struct PostalCodeElement: Codable {
    let value: String
}
