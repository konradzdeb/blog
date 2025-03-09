---
title: Using Swift for Data Science Workflows
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

The first step is to integrate a custom Swift engine into knitr. We have several goals for this setup:

1. **Maintain a cumulative namespace across chunks.**  
   If a variable `varA` is defined in the first chunk and `varB` in the second, the environment for the second chunk should include both `varA` and `varB`.

2. **Limit scope retroactively.**  
   Newly defined variables remain isolated to the chunk in which they appear, so a variable `varC` defined in the third chunk does not retroactively affect the first or second.

3. **Reduce redundant output.**  
   Minimize repeated `print` statements, ideally preserving only the final output for clarity.

This can be done using the below command [^1]. 


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
        c(x, knitr::knit_code$get(y))
    }, prior_chunk_names, init = "")
    # Filter Swift code Identify print statement lines
    print_lines <- grep("^print", collected_swift_code)
    # Keep only the last print statement
    if (length(print_lines) > 1) {
        filtered_swift_code <- collected_swift_code[-print_lines[-length(print_lines)]]  # Remove all but the last print
    } else {
        filtered_swift_code <- collected_swift_code  # Keep everything as is
    }
    # Run the collected Swift code
    out <- system2(command = "swift", args = "repl", input = filtered_swift_code,
        stdout = TRUE, stderr = TRUE)
    knitr::engine_output(options, options$code, out)
})
```

What happens here:
1. Function `knitr::knit_engines$set` registers new engine. Engine is define as new function called `swift`.
2. The call `swift_chunk_names[seq_len(Position( \(x) x == knitr::opts_current$get("label"), swift_chunk_names ))]` identifies current chunk and ensures that only the previous and the current chunk are passed into evaluation engine. Functional [`Position`](http://adv-r.had.co.nz/Functionals.html) will return a number of element meting criteria. Notation `\(x)` was introduced in R [4.1.0](https://cran.r-project.org/doc/manuals/r-release/NEWS.html) and is a shorthand for `function(x)`, e.g. `\(x) x + 1` is parsed as `function(x) x + 1`.
4. Call `Reduce( \(x, y) { paste(x, knitr::knit_code$get(y), sep = "\n") }, prior_chunk_names, init = "")` combines the previous Swift code blocks in one text.
5. Subsequent calls do a trivial vector substitution and remove all other than penultimate print statement.


## Testing

Let's attempt to evaluate a trivial statement


``` swift
import Foundation
let helloText: String = "Hello from Swift REPL"
print(helloText)
```

```
## helloText: String = "Hello from Swift REPL"
## Hello from Swift REPL
```

Let's see if we can continue using the variables created below and re-use variable from the previous statement


``` swift
let punctuationMark: String = "!"
let helloTwo:String = helloText + punctuationMark
print(helloTwo)
```

```
## helloText: String = "Hello from Swift REPL"
## punctuationMark: String = "!"
## helloTwo: String = "Hello from Swift REPL!"
## Hello from Swift REPL!
```

# Conclusion

By setting up a custom Swift engine in knitr, you can seamlessly execute Swift REPL commands within an R Markdown document and capture the output for immediate display. This allows for rapid experimentation, straightforward debugging, and convenient sharing of code alongside explanatory text—qualities essential for any data science workflow. With just a few lines of configuration, Swift’s performance and safety become accessible in an interactive environment, letting you prototype data manipulation, statistical analysis, or even machine learning models right in your R Markdown files.

[^1]: The original code was contributed via [StackOverflow discussion](https://stackoverflow.com/a/79484446/1655567); I've re-wrote it using [R's functional programming](http://adv-r.had.co.nz/Functionals.html#functionals-fp) and reduced the code to a few lines.
