import Foundation
import Ink
import Publish

public extension Plugin {
  static func linkAttributes(config: LinkAttributesConfig? = nil) -> Self {
    return Plugin(name: "LinkAttributes") { context in
      context.markdownParser.addModifier(.linkAttributes(config: config))
    }
  }
}

public struct LinkAttributesConfig {
  /// allows you to define a list of default attributes that are added to every link
  let defaultAttributes: [Attribute]
  
  /// allows you to define a list of baseURLs where the default attributes should not be added
  /// **Note:** provide empty string for links without a host (e.g. local links `/articles`)
  let defaultAttributesHostExcludeList: [String]?
  
  public init(defaultAttributes: [Attribute], defaultAttributesHostExcludeList: [String]? = nil) {
    self.defaultAttributes = defaultAttributes
    self.defaultAttributesHostExcludeList = defaultAttributesHostExcludeList
  }
}

public extension Modifier {
  
  static func linkAttributes(config: LinkAttributesConfig? = nil) -> Self {
    return Modifier(target: .links) { html, markdown in
      guard let title = markdown.content(delimitedBy: .squareBrackets) else { return html }
      guard let link = markdown.content(delimitedBy: .parentheses) else { return html }
      let parts = link.components(separatedBy: CharacterSet.whitespaces)
      
      guard let url = parts.first else { return html }
      
      guard parts.count > 1 || !(config?.defaultAttributes.isEmpty ?? true) else { return html }
      var attributes = parts
        .dropFirst()
        .compactMap(Attribute.init)
      
      if let config = config, shouldApplyDefaultAttributes(config: config, url: url) {
        config.defaultAttributes.forEach { attribute in
          // an existing attribute with the same key overrules default attributes
          if !attributes.contains(where: { $0.key == attribute.key }) {
            attributes.append(attribute)
          }
        }
      }
      
      attributes.sort(by: { $0.key < $1.key })
      
      guard !attributes.isEmpty else { return html }
      let attrs = attributes
        .map({ $0.html})
        .joined(separator: " ")
      
      return #"<a href="\#(url)" \#(attrs)>\#(title)</a>"#
    }
  }
  
  private static func shouldApplyDefaultAttributes(config: LinkAttributesConfig, url: String) -> Bool {
    
    guard let hostExcludeList = config.defaultAttributesHostExcludeList else { return true }
    
    guard let urlComponents = URLComponents(string: url) else { return false }
    
    if let host = urlComponents.host {
      return !hostExcludeList.contains(host)
    } else {
      return !hostExcludeList.contains("")
    }
  }
}
