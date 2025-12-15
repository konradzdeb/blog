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

- Run loop idle - process is idle, flush occurs
- Graceful app termination (`Cmd + Q`)
- Normal quit, pending preferences are dumped into a file
- Process life cycle switch
- switching from background to foreground
- Memory pressure - forcing cache flush to reclaim memory
- Periodic internal timers - undocumented heuristic

Given the above I was keen to observe the changes to the actual file independently; without the need to depend on a logger of debugging breakpoints. A convenient solution would be to utilise Xcode's pre-run and post-run actions. The actions can be configured using Xcode schema and are accessible via `Product` > `Scheme` > `Edit Scheme`. To achieve the desired outcome I would configure one pre-run and one post-run action

![pre-run and post-run actions](images/pre-post-actions.png)

### Pre-run Action

Majority of the work associated with building the observation pipeline is achieved in the pre-action. Initially I create a set of relevant variables and ensure that the two tools I need are available, this is achieved in via the following code:

```bash
set -euo pipefail

FSWATCH="/opt/homebrew/bin/fswatch"
PLUTIL="/usr/bin/plutil"

test -x "${FSWATCH}" || { echo "fswatch not found"; exit 1; }
test -x "${PLUTIL}" || { echo "plutil not found" ; exit 1; }

```

It is worth adding that pre-action system is known to continue with the build despite potential errors; a way of working around that could be by moving the file presence checks into the build. Following that I would create a set of relevant variables so the action can be constructed conveniently. In practice, I want to store a few key elements,

```bash
APP_GROUP_ID=" group.kz•public.swift. examples DefaultsExperiment"
GROUP_CONTAINER="$HOME/Library/Group Containers/${APP_GROUP_ID}"
PLIST="${GROUP_CONTAINER}/Library/Preferences/${APP_GROUP_ID}.plist"
LOG_DIR="${SRCROOT}/ .xcode-logs"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/defaults-watch.log"
PID_FILE="${LOG_DIR}/defaults-watch.pid"
SNAPSHOT="${LOG_DIR}/defaults-current.xml"
PREV="${LOG_DIR}/defaults-prev.xml"
```
