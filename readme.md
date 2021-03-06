# Markdown Parser v0.1.0
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](https://fantom-lang.org/)
[![pod: v0.1.0](http://img.shields.io/badge/pod-v0.1.0-yellow.svg)](http://eggbox.fantomfactory.org/pods/afMarkdownParser)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)

## Overview

*Markdown Parser is a support library that aids Alien-Factory in the development of other libraries, frameworks and applications. Though you are welcome to use it, you may find features are missing and the documentation incomplete.*

Parses Markdown text into Fandoc objects.

Supported Markdown syntax:

* Headings (with anchor links)
* Paragraphs
* Block quotes
* Lists (ordered and unordered)
* Links and images
* Bold and italics
* Code blocks and code spans (normal and Github style)


Markdown Parser uses the extensible Parsing Expression Grammer as provider by [Pegger](http://eggbox.fantomfactory.org/pods/afPegger).

Note that this markdown implementation is known to be incomplete. For example, it does not support reference links or backslash escaping `*` and `_` characters. But it should be usable to most casual users.

## <a name="Install"></a>Install

Install `Markdown Parser` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afMarkdownParser

Or install `Markdown Parser` with [fanr](https://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afMarkdownParser

To use in a [Fantom](https://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afMarkdownParser 0.1"]

## <a name="documentation"></a>Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afMarkdownParser/) - the Fantom Pod Repository.

## Usage

1 class - 1 method - 1 argument - 1 return value.

    fandoc := MarkdownParser().parse("...markdown...")

It's pretty self explanatory!

Or, for those wanting a quick fix, there's a cmd-line option that converts `.fandoc` files to `.md` files and vice-versa. The extension is auto-checked to choose an appropiate converter.

    $ fan afMarkdownParser somefile.fandoc

*(Thanks go to `LightDye` for implementing the cmd-line feature.)*

## Cheatsheet

A cheatsheet of supported markdown syntax:

    # Heading 1
    
    ## Heading 2
    
    ### Heading 3
    
    #### Heading 4
    
    #### <a name="id"></a> Heading with anchor tag
    
    This is *italic* and so is _this_
    
    This is **bold** and so is __this__
    
    These are just * stars * and _ stripes _
    
    This is a `code` span.
    
    This is a code block:
        Void main() {
            echo("Note the leading 4 spaces")
        }
    
    ```
    This is a Github style code block.
    ```
    
    Horizonal Rules:
    ----------------
    
    This is a link to [Fantom-Factory](http://www.fantomfactory.org/)
    
    ![Fanny the Fantom Image](http://www.fantomfactory.org/fanny.png)
    
    > This is a block quote. - said Fanny
    
     * An unordered list
     * An unordered list
     * An unordered list
    
     1. An ordered list
     1. An ordered list
     1. An ordered list
    

## HTML

To convert Markdown to HTML use the [HtmlDocWriter](https://fantom.org/doc/fandoc/HtmlDocWriter.html) class from the core `fandoc` pod:

    using afMarkdownParser
    using fandoc
    
    fandoc := MarkdownParser().parseStr("...markdown...")
    buf    := StrBuf()
    fandoc.writeChildren(HtmlDocWriter(buf.out))
    html   := buf.toStr
    

Note that Fantom also ships with a `FandocDocWriter` and a `MarkdownDocWriter` should you wish to print fandoc or markdown documents.

