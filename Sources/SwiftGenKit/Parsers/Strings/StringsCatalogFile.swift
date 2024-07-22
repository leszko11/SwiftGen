//
// SwiftGenKit
// Copyright © 2022 SwiftGen
// MIT Licence
//

import Foundation
import PathKit

extension Strings {
  struct File {
    let path: Path
    let name: String
    let document: Document

    init(path: Path, relativeTo parent: Path? = nil) throws {
      let data: Data = try path.read()

      self.path = parent.flatMap { path.relative(to: $0) } ?? path
      self.name = path.lastComponentWithoutExtension

      do {
        self.document = try JSONDecoder().decode(Document.self, from: data)
      } catch let DecodingError.dataCorrupted(context) {
        throw ParserError.invalidFormat(reason: context.debugDescription)
      } catch let DecodingError.keyNotFound(key, context) {
        let message = "Key '\(key)' not found:\(context.debugDescription)\ncodingPath:\(context.codingPath)"
        throw ParserError.invalidFormat(reason: message)
      } catch let DecodingError.valueNotFound(value, context) {
        let message = "Value '\(value)' not found:\(context.debugDescription)\ncodingPath:\(context.codingPath)"
        throw ParserError.invalidFormat(reason: message)
      } catch let DecodingError.typeMismatch(type, context)  {
        let message = "Type '\(type)' mismatch:\(context.debugDescription)\ncodingPath:\(context.codingPath)"
        throw ParserError.invalidFormat(reason: message)
      } catch {
        throw ParserError.invalidFormat(reason: error.localizedDescription)
      }
    }
  }

  struct Document: Decodable {
    let sourceLanguage: String
    let strings: [String: StringCatalogEntry]
  }

  struct StringCatalogEntry: Decodable {
    let comment: String?
    let localizations: [String: Localization]?
  }

  struct Localization: Decodable {
    let stringUnit: StringUnit?
    let variations: Variations?
  }

  struct Variations: Decodable {
    let plural: PluralVariation?
  }

  struct PluralVariation: Decodable {
    let zero: Variation?
    let one: Variation?
    let two: Variation?
    let few: Variation?
    let many: Variation?
    let other: Variation

    var all: [Variation] {
      [
        zero,
        one,
        two,
        few,
        many,
        other
      ].compactMap { $0 }
    }
  }

  struct Variation: Decodable {
    let stringUnit: StringUnit
  }

  struct StringUnit: Decodable {
    let value: String
  }
}
