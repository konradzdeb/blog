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

An alternative implementation would refrain from replacing the file content by writing to file and replace the content with the formatted content sourced from buffer. This function could look as follows:

```vim
function! FormatThisPythonFile()
	let filename = expand("%")
	let cmd = "autopep8 --aggressive --aggressive " . filename
	let result = system(cmd)
	execute "%d"
	put =result
	exec "1,1d"
endfunction
command FormatThisPythonFile call FormatThisPythonFile()
```

The result of the system command is stored in the `cmd` variable and subsequently pasted into the document content allowing for maintaining the document history and conveniently switching between initial and unformatted version. 

## Example

The GIF below shows changes between formatted and unformatted file following the use of the function together with history accessible via [undotree](https://github.com/mbbill/undotree).

## Notable mentions

[vim-autopep8](https://github.com/tell-k/vim-autopep8) maintained by [tell-k](https://github.com/tell-k) provides even more complete implementation taking care of such detail as cursor position and ability to format selected parts of the file. 

