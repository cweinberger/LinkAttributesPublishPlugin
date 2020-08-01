/**
 Taken from: https://github.com/finestructure/ImageAttributesPublishPlugin
 License: https://github.com/finestructure/ImageAttributesPublishPlugin/blob/master/LICENSE
 */

enum Delimiter {
  case squareBrackets
  case parentheses
  
  var opening: Character {
    switch self {
    case .squareBrackets: return "["
    case .parentheses: return "("
    }
  }
  
  var closing: Character {
    switch self {
    case .squareBrackets: return "]"
    case .parentheses: return ")"
    }
  }
}

extension Substring {
  // Naive content delimination, in the sense that it does not
  // count multiple levels of opening delimiters.
  // Simply returns string between first occurrences of opening
  // and closing delimiters.
  func content(delimitedBy delimiter: Delimiter) -> Substring? {
    guard let delimPos = self.firstIndex(of: delimiter.opening) else { return nil }
    let start = self.index(after: delimPos)
    guard let end = self.firstIndex(of: delimiter.closing) else { return nil }
    guard start <= end else { return nil }
    return self[start..<end]
  }
}

public struct Attribute {
  var key: String
  var value: String
  
  public init(key: String, value: String) {
    self.key = key
    self.value = value
  }
  
  init?(_ rawValue: String) {
    let pair = rawValue.split(separator: "=").map(String.init)
    guard pair.count == 2 else { return nil }
    key = pair[0]
    value = pair[1]
  }
  
  var html: String {
    "\(key)=\"\(value)\""
  }
}
