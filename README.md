# unibits | Reveal the Unicode [![[version]](https://badge.fury.io/rb/unibits.svg)](http://badge.fury.io/rb/unibits)  [![[travis]](https://travis-ci.org/janlelis/unibits.svg)](https://travis-ci.org/janlelis/unibits)

Ruby library and CLI command that visualizes various Unicode and ASCII/single byte encodings in the terminal:

- Makes analyzing encodings easier
- Helps you with debugging strings
- Highlights invalid/special/blank bytes/characters/codepoints
- Supports *UTF-8*, *UTF-16LE*/*UTF-16BE*, *UTF-32LE*/*UTF-32BE*, *ISO-8859-X*, *Windows-125X*, *IBMX*, *CP85X*, *macX*, *TIS-620*/*Windows-874*, *KOI8-R*/*KOI8-U*, 7-Bit *ASCII*, and arbitrary *BINARY* data

## Color Coding

Each byte of the given string is highlighted using the following mechanism (characters -> codepoints):

- Red for invalid bytes
- Orange for unassigned bytes/characters
- Light blue for blanks
- Blue for control characters
- Non-control formatting characters in pink
- Green for marks (Unicode only)
- Random color for all other characters

## Setup

Make sure you have Ruby installed and installing gems works properly. Then do:

```
$ gem install unibits
```

## Usage

Pass the string to debug to unibits:

### From CLI

```
$ unibits "🌫 Idio﻿syncrätic ℜսᖯʏ"
```

### From Ruby

```ruby
require 'unibits/kernel_method'
unibits "🌫 Idio﻿syncrätic ℜսᖯʏ"
```

### Advanced Options

`unibits` takes some optional options:

- *encoding (e)*: The encoding of the given string (uses the string's default encoding if none given)
- *convert (c)*: An encoding the string should be converted to before visualizing it
- *stats*: Whether to show a short stats header (default: `true`), you can deactivate on the CLI with `--no-stats`
- *wide-ambiguous*: Treat characters of ambiguous width as 2 spaces instead of 1 ([more info](https://github.com/janlelis/unicode-display_width))
- *width (w)*: Set a custom column width, if not set, *unibits* will retrieve it from the terminal or just use 80

## Examples of Valid Encodings
### UTF-8

CLI: `$ unibits -e utf-8 -c utf-8 "🌫 Idio﻿syncrätic ℜսᖯʏ"`

Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'utf-8', convert: 'utf-8'`

![Screenshot UTF-8](/screenshots/utf-8.png?raw=true "UTF-8")

### UTF-16LE

CLI: `$ unibits -e utf-8 -c utf-16le "🌫 Idio﻿syncrätic ℜսᖯʏ"`

Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'utf-8', convert: 'utf-16le'`

![Screenshot UTF-16LE](/screenshots/utf-16le.png?raw=true "UTF-16LE")

### UTF-32BE

CLI: `$ unibits -e utf-8 -c utf-32be "🌫 Idio﻿syncrätic ℜսᖯʏ"`

Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'utf-8', convert: 'utf-32be'`

![Screenshot UTF-32BE](/screenshots/utf-32be.png?raw=true "UTF-32BE")

### BINARY

CLI: `$ unibits -e binary "🌫 Idio﻿syncrätic ℜսᖯʏ"`

Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'binary'`

![Screenshot BINARY](/screenshots/binary.png?raw=true "BINARY")

### ASCII

CLI: `$ unibits -e utf-8 -c ascii "ascii"`

Ruby: `unibits "ascii", encoding: 'utf-8', convert: 'ascii'`

![Screenshot ASCII](/screenshots/ascii.png?raw=true "ASCII")

## Examples of Invalid Encodings
### UTF-8

Example in Ruby: `unibits "unexpected \x80 | not enough \xF0\x9F\x8C | overlong \xE0\x81\x81 | surrogate \xED\xA0\x80 | too large \xF5\x8F\xBF\xBF"`

![Screenshot invalid UTF-8](/screenshots/utf-8.invalid.png?raw=true "Invalid UTF-8")

### ASCII

Example in Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'ascii'`

![Screenshot invalid ASCII](/screenshots/ascii.invalid.png?raw=true "Invalid ASCII")

## Notes

Also see

- [Ruby's Encoding class](https://ruby-doc.org/core/Encoding.html)
- [Characteristics gem](https://github.com/janlelis/characteristics)
- [UTF-8 (Wikipedia)](https://en.wikipedia.org/wiki/UTF-8#Description)
- [UTF-16 (Wikipedia)](https://en.wikipedia.org/wiki/UTF-16#Description)
- [UTF-32 (Wikipedia)](https://en.wikipedia.org/wiki/UTF-32)
- [Difference between BINARY and ASCII](http://idiosyncratic-ruby.com/56-us-ascii-8bit.html)
- [Unicode Micro Libraries for Ruby](https://github.com/janlelis/unicode-x)

Lots of thanks to @damienklinnert for the motivation and inspiration required to build this! 🎆

Copyright (C) 2017 Jan Lelis <http://janlelis.com>. Released under the MIT license.
