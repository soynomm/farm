# Farm

**Farm** is a static content engine written in Swift, for Swift projects. It powers my [personal site](https://askonomm.com) and is meant to be used for sites with static content, such as blogs or websites, either as a complimentary addition or the sole thing driving it - that's for you to decide.

### Example content file

All of the content files in **Farm** are Markdown files. That means they have a file name of `example.md`. They can be in any directory you want (you can specify it) and they contain YAML metadata. An example of a Farm file is the following (probably a familiar format if you've used Jekyll before):

```
---
date: 2019-02-18
status: public
slug: example-url-slug
title: Example page
---

Example content in **Markdown** goes here.
```

This would create the following `FarmItem` struct: 

```Swift
public struct FarmItem: Codable {
  public var meta: [String: String]
  public var entry: String
}
```

### Installation

To install Farm, simply require it in your Package.swift file like this:

```Swift
dependencies: [
    .package(name: "Farm", url: "https://git.sr.ht/~askonomm/farm", from: "1.0.1"),
]
```

### Changelog

To be written.

### Usage

#### Retrieving all content in a directory

To retrieve all of the content in a directory, simply initialize Farm with your provided directory and call `getAll()` on it, like this:

```Swift
import Farm

let content = Farm(directory: "./Blog/")
let items = content.getAll()
```

This will return you an array of `FarmItem` objects.

#### Retreving a specific item in a directory

To retrieve a specific content item in a directory, initialize Farm and call `get(key: "yamlKey", value: "yamlValue")` on it (where key and value is corresponding with the YAML key and value in the file), like this:

```Swift
import Farm

let content = Farm(directory: "./Blog/")
let item = content.get(key: "slug", value: "hello-world")
```

This will return you a `FarmItem` object.

#### Ordering content

You can order content by any meta key in descending or ascending order. For example; if we want to order content by the meta key `date` in a descending order, we would do the following

```Swift
import Farm

let content = Farm(directory: "./Blog/", orderBy: "date", order: "desc")
```

Likewise if you want it to be in ascending order, simply change `order` to `asc`. 
