---
title: Using build pre-post actions to observe default changes
author: Konrad Zdeb
date: 2025-11-24T16:01:56.305Z
bodyClass: "widecode"
categories:
  - dev
tags:
  - Swift
  - Xcode
  - macOS
draft: false
description: How to exploit pre-/-post-actions available in Xcode to observe changes in defaults.
slug: build-pre-post-actions-observe-default
---

The following article provides guide on scheme build and run (pre-)post actions in Xcode to manage creation and modification of defaults through external logging through the application.

## What are Defaults?

In Swift and macOS development, defaults (via `UserDefaults` and the `defaults` CLI) are the lightweight persistence layer for user preferences, feature toggles, and other small pieces of state that need to survive app relaunches. They sit between in-memory settings and heavier storage options, letting you read and write simple values keyed by domain so the same code works in app code, Xcode schemes, and shell scripts. Because defaults are global to a domain, careful naming and cleanup are essential to avoid collisions and stale settings during development.

For a deeper dive, Fatbobman’s [“UserDefaults and Observation in SwiftUI”](https://fatbobman.com/en/posts/userdefaults-and-observation/) is a solid blueprint: Xu Yang shows why Observation alone misses external changes, then patches the gap with an `@ObservableDefaults` macro that keeps SwiftUI views in sync with UserDefaults regardless of where writes originate. This is, excellent, disciplined approach which centralizes keys, respond to external mutations, and chooses lightweight persistence over ad-hoc state—maps well. For the remaining part of this article I will be using this approach.

## Challenge

When building a macOS application that stores defaults I was keen to see what the application writes to the defaults store. In particular, I would like to be able to see what is actually being written by the application the disk.

## Solution

My preferred solution to the problem is to create a designed Xcode schema, which I would use to track the defaults journey. I have created basic macOS application and a set of defaults following guidance in [“UserDefaults and Observation in SwiftUI”](https://fatbobman.com/en/posts/userdefaults-and-observation/). Initially I define a set of defaults that will carry some basic inputs from the application using `ObservableObject`

### The App Structure

```swift
import SwiftUI
import Combine

class Defaults: ObservableObject {
    @AppStorage("custom_toggle", store: .group) var customToggle: Bool = false
    @AppStorage("custom_integer", store: .group) var customInteger: Int = 1
    @AppStorage("custom_string", store: .group) var customString: String = "abc"
}
```

Adding a `.group` parameter is a good practice that permits for convenient sharing of default values across targets. To understand and read more about default groups look at the article here. I define my static group property as follows:

```swift
import Foundation

extension UserDefaults {
    static let group: UserDefaults = {
        let staticString: String = "group.xz.public.swift.examples.DefaultsExperiment"
        if let teamIdentifierPrefix = Bundle.main.object(forInfoDictionaryKey: "Team Identifier Prefix") as? String {
            return UserDefaults(
                suiteName: teamIdentifierPrefix + staticString
            ) ?? UserDefaults.standard
        } else {
            return UserDefaults(suiteName: staticString) ?? UserDefaults.standard
        }
    }()
}
```

Given the above basics I would incorporate a trivial view in SwiftUI providing ability to modify the stored preferences in a simple manner.

```swift
import SwiftUI

struct ContentView: View {

    @StateObject var defaults = Defaults()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Custom Toggle: \(defaults.customToggle ? "On" : "Off")", isOn: defaults.$customToggle)
            Stepper("Custom Integer: \(defaults.customInteger)", value: defaults.$customInteger)
            VStack(alignment: .leading, spacing: 4) {
                Text("Custom String:")
                TextField("abc", text: defaults.$customString)
            }
        }
        .padding()
    }
}

```

### Observing the Observable Defaults

Now the key element - how to conveniently observe changes to the defaults? From within the Xcode we could use few of the standard methods such as calling logger via `OSlogger` or using breakpoints. However, Apple's implementation deliberately decouples _mutation_ from _persistence_. In practice, all I/O operations go through memory cache and persistence to disk is deferred and opportunistic. Write-trigger usually occurs during one of the following events:
