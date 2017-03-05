# unibits [![[version]](https://badge.fury.io/rb/unibits.svg)](http://badge.fury.io/rb/unibits)  [![[travis]](https://travis-ci.org/janlelis/unibits.svg)](https://travis-ci.org/janlelis/unibits)

Ruby library and CLI command that visualizes various Unicode and ASCII encodings in the terminal.

Helps you debugging and learning about Unicode encodings.

Supported encodings: **UTF-8**, **UTF-16LE**, **UTF-16BE**, **UTF-32LE**, **UTF-32BE**, **BINARY**, **ASCII**

## Setup

```
$ gem install unibits
```

## Usage
### From CLI

```
$ unibits "🌫 Idio﻿syncrätic ℜսᖯʏ"
```

### From Ruby

```ruby
require 'unibits/kernel_method'
unibits "🌫 Idio﻿syncrätic ℜսᖯʏ"
```

### Options

`unibits` takes three optional options:

- *encoding (e)*: The encoding of the given string (uses your default encoding if none given)
- *convert (c)*: An encoding the string should be converted to before visualizing it
- *stats*: Whether to show a short stats header (default: `true`), you can deactivate on the CLI with `--no-stats`

**Please note**: This uses Ruby's built-in encoding support. Currently, only strings with valid encodings are supported.

## Output for Different Encodings
### UTF-8

CLI: `$ unibits -e utf-8 -c utf-8 "🌫 Idio﻿syncrätic ℜսᖯʏ"`

Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'utf-8', convert: 'utf-8'`

![Screenshot UTF-8](/screenshots/utf-8.png?raw=true "UTF-8")

### UTF-16LE

CLI: `$ unibits -e utf-8 -c utf-16le "🌫 Idio﻿syncrätic ℜսᖯʏ"`

Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'utf-8', convert: 'utf-16le'`

![Screenshot UTF-16LE](/screenshots/utf-16le.png?raw=true "UTF-16LE")

### UTF-16BE

CLI: `$ unibits -e utf-8 -c utf-16be "🌫 Idio﻿syncrätic ℜսᖯʏ"`

Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'utf-8', convert: 'utf-16be'`

![Screenshot UTF-16BE](/screenshots/utf-16be.png?raw=true "UTF-16BE")

### UTF-32LE

CLI: `$ unibits -e utf-8 -c utf-32le "🌫 Idio﻿syncrätic ℜսᖯʏ"`

Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'utf-8', convert: 'utf-32le'`

![Screenshot UTF-32LE](/screenshots/utf-32le.png?raw=true "UTF-32LE")

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

Ruby: `unibits "ASCII String", encoding: 'utf-8', convert: 'ascii'`

![Screenshot ASCII](/screenshots/ascii.png?raw=true "ASCII")

## Notes

Also see

- [UTF-8 (Wikipedia)](https://en.wikipedia.org/wiki/UTF-8#Description)
- [UTF-16 (Wikipedia)](https://en.wikipedia.org/wiki/UTF-16#Description)
- [UTF-32 (Wikipedia)](https://en.wikipedia.org/wiki/UTF-32)
- [Ruby's Encoding class](https://ruby-doc.org/core/Encoding.html)
- [Unicode Micro Libraries for Ruby](https://github.com/janlelis/unicode-x)

Lots of thanks to @damienklinnert for the motivation and inspiration required to build this! 🎆

Copyright (C) 2017 Jan Lelis <http://janlelis.com>. Released under the MIT license.
