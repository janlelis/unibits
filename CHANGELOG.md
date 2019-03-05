## CHANGELOG

### 2.8.0

* Unicode 12

### 2.7.0

* Unicode 11

### 2.6.0

* Support Unicode 10.0

### 2.5.0

* Double check UTF-32 only on Ruby versions which contain the bug
* Highlight unassigned codepoints which are ignorable
* Bump symbolify dependency
  * Add special characters (U+FFF9 - U+FFFC)
  * Non-control separators return ⏎
* Bump characteristics dependency
  * Allow GB1988 encoding (7bit ascii-like)

### 2.4.0

* Extract symbolification logic into extra [symbolify](https://github.com/janlelis/symbolify) gem (includes fixes and non-character detection)
* Update characteristics gem (includes a new blank)

### 2.3.0

* More consistent handling of bidi controls (always symbolify with alias, but highlight ALM, RLM, LRM as blanks)
* Highlight control chars that are also blanks as blank
* Highlight CGJ as blank
* Highlight NEL as blank (only in Unicode)
* Add Unicode version to `unibits --version` command

### 2.2.0

* Add mongolian free variation selectors and combining grapheme joiner to interesting codepoints list
* Green highlighting of "marks" in Unicode
* Always use dotted circle for non-spacing marks
* Always prepend enclosing marks with a space
* Update characteristics gem (includes new blanks and UTF-8 dialects with japanese emojis)

### 2.1.1

* Proper UTF-32 validness / invalid codepoint highlighting, see https://bugs.ruby-lang.org/issues/13292

### 2.1.0

* Support more encoding: IBMX, CP85X, macX, TIS-620/Windows-874, and KOI8-X
* Highlight non-control formatting characters in pink
* Improve `unibits --help` command

### 2.0.0

* Support more encodings: ISO-8859-X and Windows-125X
* Add three HANGUL characters (U+115F, U+1160, U+3164) to list of possible white spaces
* Move character handling to separate gem. It is called [characteristics](https://github.com/janlelis/characteristics).
* Highlight control chars in blue and blanks in light blue
* Handle encodings that are not convertible to UTF-8

### 1.3.0

* Add variation selectors 17-256 (U+E0100 - U+E01EF)
* Add U+1D159 (MUSICAL SYMBOL NULL NOTEHEAD) to list of possible white spaces
* Bump unicode-categories dependency for more reliable unassigned codepoint detection

### 1.2.1

* Fix bug that inserted wrong bytes

### 1.2.0

* Do not display (but highlight) unassigned codepoints

### 1.1.0

* Support (and highlight) invalid encodings \o/
* Improve character symbolification
* Fix that the Kernel method would not take keyword arguments
* New option for setting a custom output width to use
* New option for activating wide ambiguous characters

### 1.0.0

* Initial release

