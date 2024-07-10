---
title: Aggresively formating your Python files
author: Konrad Zdeb
date: '2023-09-30'
slug: []
categories:
  - how-to
tags:
  - Python
  - vim
  - VimL
---

Vim offers variety of functions that can be used to format files. Starting with basic functionalities, like `reident`

## VimL Implementation 

Creating a function within Vim to process the file is, likely, the most straightforward choice. In effect, the role of the function is to pass the filename to the call below:

```shell
autopep8 --verbose --in-place --aggressive --aggressive   ${our_python_file}
```

In this implementation file path is passed into the formatting function and formatted file is then read back into the buffer.

```vim
" Aggresively and quickly format Python file
function! FormatThisPythonFile()
	 let filename = expand("%")
	 let cmd = "autopep8 --verbose --in-place --aggressive --aggressive " . filename
	 let result = system(cmd)
	 execute(':edit! ' . filename)
	 echo result
endfunction
```

This implementation has a few major drawbacks:

* In order to pass the most recent content of the file into the `autopep8` the file has to be saved
* More importantly, the history of the file is also lost at this stage

An alternative implementation would refrain from replacing the file content by writing to file and replace the content with the 

## Notable mentions

Autopep8 

