---
title: Using Swift for Data Science
author: Konrad Zdeb
date: '2025-03-04'
slug: swift-data-science
categories:
  - example
  - Data Science
tags:
  - Swift
  - knitr
---




# Why Swift?

Data science is dominated by Python and R, with some usage of Julia, Scala, Java, and C++. While Swift may not be the most popular choice, it offers several notable benefits—especially for developers already invested in the Apple ecosystem.

## Key Advantages

- **Performance Considerations**  
  As a compiled language, Swift often runs faster than languages like Python or R. This can be especially beneficial when handling large datasets or complex computations.

- **Safety & Reliability**  
  Swift’s strong type system, optional handling, and memory safety features help you write more robust and secure code with fewer runtime errors.

- **Ecosystem & Tooling**  
  Several libraries and frameworks support data science in Swift, such as [Swift Numerics](https://github.com/apple/swift-numerics) for numerical computing and [Swift for TensorFlow](https://github.com/tensorflow/swift) for machine learning.

- **Integration with Existing Codebases**  
  Swift integrates smoothly with existing iOS and macOS projects or C/C++ libraries. This allows teams to unify app logic and data science components under one language and codebase.

## Commercialization Potential

For projects intended for the Apple ecosystem, Swift-based development can streamline the path from prototype to product. Reusing large parts of your data science pipeline directly within an iOS or macOS app reduces development overhead. This level of end-to-end integration is often more cumbersome when using non-Swift languages, making Swift an attractive option for commercial applications.

# Initial Configuration

In data science workflows, the Swift [REPL (Read-Eval-Print Loop)](https://swift.org/documentation/) provides an interactive environment that runs Swift code line by line, making it easy to test ideas and quickly prototype. In this blog post, I will use the Swift REPL within an R Markdown document by leveraging the [`knitr` package](https://cran.r-project.org/web/packages/knitr/index.html). This setup allows me to execute Swift code blocks directly while seamlessly incorporating the output into the rendered document, streamlining both experimentation and content creation.

## Adding Swift as engine to `knitr`

The first step is to add Swift engine to knitr. We have a few objectives for that function:
1. We need to keep accumulating created objects, i.e. if in a previous chunk we have defined a variable `varA` and in the second chunk we have defined `varB` we would like for the second namespace utilised in evaluation of second chunk to contain `varA` and `varB`.
2. On the same lines, if we have defined `varC` in thrid chunk we would like for that variable to made availale only in the third chunk but not in the first two.
3.  We would like to exclude 
This can be done using the below command[^1]. 


``` r
# Wrap code chunks
knitr::opts_chunk$set(tidy.opts = list(width.cutoff = 80), tidy = TRUE)

# Define Swift as engine
knitr::knit_engines$set(swift = function(options) {
    # Get all Swift chunks
    swift_chunk_names <- knitr::all_labels(engine == "swift")
    # Preceding chunks
    prior_chunk_names <- swift_chunk_names[seq_len(Position(\(x) x == knitr::opts_current$get("label"),
        swift_chunk_names))]
    # All Swift code
    collected_swift_code <- Reduce(\(x, y) {
        paste(x, knitr::knit_code$get(y), sep = "\n")
    }, prior_chunk_names, init = "")
    # Filter Swift code
    filtered_swift_code <- Filter(\(x) {
        !grepl(".*print.*", x)
    }, collected_swift_code)
    # Run the collected Swift code
    out <- system2(command = "swift", args = "repl", input = filtered_swift_code,
        stdout = TRUE, stderr = TRUE)
    knitr::engine_output(options, options$code, out)
})
```

What happens here:
1. Function `knitr::knit_engines$set` registers new engine. Engine is define as new function called `swift`
2. Call `paste` with argument `collapse = '\n'`
3. Call `system2` is responsible for passing the actual command


## Testing

Let's attempt to evaluate a trivial statement


``` swift
import Foundation
let helloText: String = "Hello from Swift REPL"
print(helloText)
```

```
## helloText: String = "Hello from Swift REPL"
```

Let's see if we can continue using the variables created below and re-use variable from the previous satetement


``` swift
let punctuationMark: String = "!"
let helloTwo:String = helloText + punctuationMark
print(helloTwo)
```

```
## punctuationMark: String = "!"
## helloText: String = "Hello from Swift REPL"
## helloTwo: String = "Hello from Swift REPL!"
```

[^1]: The original code was contributed via [StackOverflow discussion](https://stackoverflow.com/a/79484446/1655567); I've re-wrote it using [R's functional programming](http://adv-r.had.co.nz/Functionals.html#functionals-fp) and reduced the code to ~6 lines.
