# LinkAttributes plugin for Publish

A [Publish](https://github.com/johnsundell/publish) plugin that allows you to specify link attributes.

Heavily inspired by https://github.com/finestructure/ImageAttributesPublishPlugin 🙌

## What it does

Markdown:
```markdown
[cweinberger.dev](https://cweinberger.dev rel=no-follow target=_blank)
```
Resulting HTML:
```html
<p><a href="https://cweinberger.dev" rel="no-follow" target="_blank">cweinberger.dev</a></p>
```

## Installation

To install **LinkAttributesPlugin** into your [Publish](https://github.com/johnsundell/publish) package, add it as a dependency to your `Package.swift` manifest:

```swift
let package = Package(
  // ...
  dependencies: [
    // ...
    .package(name: "LinkAttributesPublishPlugin", url: "https://github.com/cweinberger/LinkAttributesPublishPlugin", from: "1.0.0")
  ],
  targets: [
    .target(
      // ...
      dependencies: [
        // ...
        "LinkAttributesPublishPlugin"
      ]
    )
  ]
  // ...
)
```

## Usage

Add this plugin to your publishing steps:
```swift
import LinkAttributesPublishPlugin
...
try DeliciousRecipes().publish(using: [
  .installPlugin(.linkAttributes())
  ...
])
```

## Default Attributes

You can add default attributes (e.g. `target="_blank"`) to all your links:
```swift
let linkConfig = LinkAttributesConfig(
  defaultAttributes: [.init(key: "target", value: "_blank")]
)
try DeliciousRecipes().publish(using: [
  .installPlugin(.linkAttributes(config: linkConfig))
  ...
])
```

## Exclude Hosts From Adding Default Attributes

You can also exclude hosts from getting default attributes added:

```swift
let linkConfig = LinkAttributesConfig(
  defaultAttributes: [.init(key: "target", value: "_blank")],
  defaultAttributesHostExcludeList: [
    "cweinberger.dev", // dont' add default attributes to websites with this hostname
    "",                // dont' add default attributes to websites without a hostname (relative links)
  ]
)

try DeliciousRecipes().publish(using: [
    .installPlugin(.linkAttributes(config: linkConfig))
    ...
])
