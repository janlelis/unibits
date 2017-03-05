# unibits [![[version]](https://badge.fury.io/rb/unibits.svg)](http://badge.fury.io/rb/unibits)  [![[travis]](https://travis-ci.org/janlelis/unibits.svg)](https://travis-ci.org/janlelis/unibits)

Ruby library and CLI command that visualizes various Unicode and ASCII encodings in the terminal.

Supported encodings:

- UTF-8
- UTF-16LE
- UTF-16BE
- UTF-32LE
- UTF-32BE
- BINARY
- ASCII

## Setup

```
$ gem install unibits
```

## Usage

### From CLI

```
unibits "🌫 Idio﻿syncrätic ℜսᖯʏ"
```

### From Ruby

```ruby
require 'unibits/kernel_method'
unibits "🌫 Idio﻿syncrätic ℜսᖯʏ"
```

### Options

`unibits` takes two optional options:

- *encoding (e)*: The encoding of the given string (uses your default encoding if none given)
- *convert (c)*: An encoding the string should be converted to before visualizing it

**Please note**: This uses Ruby's built-in encoding support. Currently, only strings with valid encodings are supported.

## Encodings
### UTF-8

CLI: `unibits -e utf-8 -c utf-8`
Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'utf-8', convert: 'utf-8'`

### UTF-16LE

CLI: `unibits -e utf-8 -c utf-8`
Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'utf-8', convert: 'utf-8'`

### UTF-16BE

CLI: `unibits -e utf-8 -c utf-8`
Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'utf-8', convert: 'utf-8'`

### UTF-32LE

CLI: `unibits -e utf-8 -c utf-8`
Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'utf-8', convert: 'utf-8'`

### UTF-32BE

CLI: `unibits -e utf-8 -c utf-8`
Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'utf-8', convert: 'utf-8'`

### BINARY

CLI: `unibits -e binary`
Ruby: `unibits "🌫 Idio﻿syncrätic ℜսᖯʏ", encoding: 'binary'`

### ASCII

CLI: `unibits -e utf-8 -c ascii`
Ruby: `unibits "ASCII String", encoding: 'utf-8', convert: 'ascii'`

## Misc Unicode Links

…

## MIT License

Copyright (C) 2017 Jan Lelis <http://janlelis.com>. Released under the MIT license.
