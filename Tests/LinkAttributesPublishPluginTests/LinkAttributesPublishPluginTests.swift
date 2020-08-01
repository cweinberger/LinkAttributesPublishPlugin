@testable import LinkAttributesPublishPlugin
import Ink
import XCTest


final class LinkAttributesPublishPluginTests: XCTestCase {
  
  func test_content_delimitedBy() throws {
    XCTAssertEqual("foo [bar] baz".content(delimitedBy: .squareBrackets), "bar")
    XCTAssertEqual("foo ]bar] baz".content(delimitedBy: .squareBrackets), nil)
    XCTAssertEqual("foo ]bar[ baz".content(delimitedBy: .squareBrackets), nil)
    XCTAssertEqual("foo (bar) baz".content(delimitedBy: .parentheses), "bar")
    XCTAssertEqual("foo (bar[) baz".content(delimitedBy: .parentheses), "bar[")
    XCTAssertEqual("foo (b[ar]) baz".content(delimitedBy: .parentheses), "b[ar]")
    XCTAssertEqual("foo (".content(delimitedBy: .parentheses), nil)
    XCTAssertEqual("foo ()".content(delimitedBy: .parentheses), "")
    XCTAssertEqual("foo )".content(delimitedBy: .parentheses), nil)
  }

  func test_parse_no_attributes() throws {
    let parser = MarkdownParser(modifiers: [.linkAttributes()])
    let html = parser.html(from: "[cweinberger.dev](https://cweinberger.dev)")
    XCTAssertEqual(html, #"<p><a href="https://cweinberger.dev">cweinberger.dev</a></p>"#)
  }
  
  func test_parse_single_attribute() throws {
    let parser = MarkdownParser(modifiers: [.linkAttributes()])
    let html = parser.html(from: "[cweinberger.dev](https://cweinberger.dev target=_blank)")
    XCTAssertEqual(html, #"<p><a href="https://cweinberger.dev" target="_blank">cweinberger.dev</a></p>"#)
  }
  
  func test_parse_multiple_attributes() throws {
    let parser = MarkdownParser(modifiers: [.linkAttributes()])
    let html = parser.html(from: "[cweinberger.dev](https://cweinberger.dev target=_blank rel=no-follow)")
    XCTAssertEqual(html, #"<p><a href="https://cweinberger.dev" rel="no-follow" target="_blank">cweinberger.dev</a></p>"#)
  }
  
  func test_default_attributes() throws {
    let parser = MarkdownParser(modifiers: [.linkAttributes(config: .init(defaultAttributes: [Attribute(key: "target", value: "_blank"), Attribute(key: "rel", value: "no-follow")]))])
    let html = parser.html(from: "[cweinberger.dev](https://cweinberger.dev)")
    XCTAssertEqual(html, #"<p><a href="https://cweinberger.dev" rel="no-follow" target="_blank">cweinberger.dev</a></p>"#)
  }
  
  func test_default_attributes_not_overriding_existing_attribute() throws {
    let parser = MarkdownParser(modifiers: [.linkAttributes(config: .init(defaultAttributes: [Attribute(key: "target", value: "_blank"), Attribute(key: "rel", value: "no-follow")]))])
    let html = parser.html(from: "[cweinberger.dev](https://cweinberger.dev target=_self)")
    XCTAssertEqual(html, #"<p><a href="https://cweinberger.dev" rel="no-follow" target="_self">cweinberger.dev</a></p>"#)
  }
  
  func test_default_attributes_with_filteredBaseURL() throws {
    let parser = MarkdownParser(modifiers: [.linkAttributes(config: .init(
      defaultAttributes: [Attribute(key: "target", value: "_blank"), Attribute(key: "rel", value: "no-follow")],
      defaultAttributesHostExcludeList: ["", "cweinberger.dev"]))]
    )
    let html1 = parser.html(from: "[cweinberger.dev](https://cweinberger.dev target=_self)")
    XCTAssertEqual(html1, #"<p><a href="https://cweinberger.dev" target="_self">cweinberger.dev</a></p>"#)
    
    let html2 = parser.html(from: "[cweinberger.dev](/articles)")
    XCTAssertEqual(html2, #"<p><a href="/articles">cweinberger.dev</a></p>"#)
    
    let html3 = parser.html(from: "[google.com](https://google.com)")
    XCTAssertEqual(html3, #"<p><a href="https://google.com" rel="no-follow" target="_blank">google.com</a></p>"#)
  }
  
  static var allTests = [
    ("test_parse_no_attributes", test_parse_no_attributes)
  ]
}

extension String {
    // Test convenience so we can test with String rather than have to construct
    // substrings
    func content(delimitedBy delimiter: Delimiter) -> String? {
        (self[...] as Substring).content(delimitedBy: delimiter).map(String.init)
    }
}
